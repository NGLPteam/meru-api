# frozen_string_literal: true

module Harvesting
  module Entities
    # @see Harvesting::Entities::Upsert
    # @see Harvesting::Entities::UpsertJob
    class Upserter < Support::HookBased::Actor
      include Harvesting::Attempts::EntityLinks::Loading
      include Harvesting::Middleware::ProvidesHarvestData
      include Harvesting::WithLogger
      include Dry::Initializer[undefined: false].define -> do
        param :harvest_entity, Harvesting::Types::Entity

        option :inline, Harvesting::Types::Bool, default: proc { false }
      end

      include MeruAPI::Deps[
        attach_contribution: "harvesting.contributions.attach",
        connect_link: "links.connect",
        find_existing_collection: "harvesting.utility.find_existing_collection",
      ]

      delegate :has_existing_parent?, :existing_parent, to: :harvest_entity

      # @return [ChildEntity]
      attr_reader :actual_entity

      # @return [String]
      attr_reader :advisory_key

      # @return [Boolean]
      attr_reader :cancelled

      alias cancelled? cancelled

      # @return [Boolean]
      attr_reader :has_children

      alias has_children? has_children

      # @return [HarvestAttemptEntityLink]
      attr_reader :link

      # @return [Boolean]
      attr_reader :modified

      alias modified? modified

      # @return [HarvestTarget, nil]
      attr_reader :parent

      delegate :harvest_record, :has_assets?, :root?, to: :harvest_entity

      delegate :harvest_configuration, :harvest_source, to: :harvest_record

      delegate :harvest_attempt, to: :harvest_configuration, allow_nil: true

      delegate :cancelled?, to: :harvest_attempt, prefix: true, allow_nil: true

      standard_execution!

      around_execute :refresh_orderings_asynchronously!

      around_execute :provide_harvest_entity!

      around_execute :provide_harvest_record!

      around_execute :provide_harvest_configuration!

      around_execute :provide_harvest_attempt!

      around_execute :provide_harvest_source!

      # @return [Dry::Monads::Success(void)]
      def call
        run_callbacks :execute do
          yield prepare!

          yield check!

          yield perform_upsert!
        end

        link.try(:transition_to, "upserted")

        Success()
      end

      wrapped_hook! def prepare
        harvest_entity.clear_harvest_errors!

        @actual_entity = nil

        @cancelled = false

        @parent = find_parent

        @has_children = harvest_entity.children.exists?

        @link = load_harvest_attempt_entity_link

        @modified = false

        @advisory_key = harvest_entity.identifier

        super
      end

      wrapped_hook! def check
        # :nocov:
        if @parent.nil?
          logger.fatal "Could not derive root parent (missing harvest configuration?)."

          @cancelled = true
        end
        # :nocov:

        if harvest_attempt_cancelled?
          logger.debug "Harvest attempt has been cancelled, skipping."

          @cancelled = true
        end

        super
      end

      # A wrapper step
      wrapped_hook! def perform_upsert
        # :nocov:
        return super if cancelled?
        # :nocov:

        @advisory_key = [parent.identifier, harvest_entity.identifier].join(?:)

        yield upsert_entity!

        yield attach_contributions!

        yield upsert_links!

        yield maybe_enqueue_children!

        yield maybe_enqueue_assets!
      rescue Harvesting::Error => e
        logger.fatal e.message, tags: %i[entity_upsert_failure], exception_klass: e.class.name, backtrace: e.backtrace

        Success nil
      else
        Success nil
      end

      wrapped_hook! def upsert_entity
        @actual_entity = find_actual_entity!

        maybe_apply_data!

        finalize_connection!

        super
      end

      around_upsert_entity :acquire_entity_lock!
      around_upsert_entity :track_upsert_duration!

      wrapped_hook! def attach_contributions
        harvest_entity.harvest_contributions.find_each do |harvest_contribution|
          yield attach_contribution.call(harvest_contribution, actual_entity)
        end

        super
      end

      wrapped_hook! def upsert_links
        harvest_entity.extracted_links.incoming_collections.each do |source|
          collection = existing_collection_from! source.identifier

          yield connect_link.call(collection, actual_entity, source.operator)
        end

        super
      end

      wrapped_hook! def maybe_enqueue_children
        # :nocov:
        return super unless has_children?
        # :nocov:

        harvest_entity.children.find_each do |child|
          if inline
            yield child.upsert(inline:)
          else
            Harvesting::Entities::UpsertJob.perform_later child
          end
        end

        super
      end

      wrapped_hook! def maybe_enqueue_assets
        # :nocov:
        return super unless has_assets?
        # :nocov:

        Harvesting::Entities::UpsertAssetsJob.set(wait: 10.seconds).perform_later harvest_entity

        super
      end

      private

      # @return [void]
      def acquire_entity_lock!
        harvest_entity.with_lock do
          ApplicationRecord.with_advisory_lock!(advisory_key, disable_query_cache: true, transaction: true, timeout_seconds: 60) do
            yield
          end
        end
      end

      # @param [String, nil] identifier
      # @return [Collection, nil]
      def existing_collection_from!(identifier)
        find_existing_collection.(identifier)
      rescue ActiveRecord::RecordNotFound
        raise Harvesting::Metadata::Error, "Unknown existing collection: #{identifier}"
      rescue LimitToOne::TooManyMatches
        raise Harvesting::Metadata::Error, "Tried to link non-global identifier: #{identifier}"
      end

      # @return [void]
      def finalize_connection!
        # :nocov:
        return unless actual_entity.try(:persisted?)
        # :nocov:

        harvest_entity.entity = actual_entity

        harvest_entity.save!(validate: false)
      end

      # @param [HarvestEntity] harvest_entity
      # @return [ChildEntity]
      def find_actual_entity!
        parent.find_or_initialize_harvested_child_for(harvest_entity)
      end

      # @return [HarvestTarget]
      def find_parent
        if root?
          default_target_entity = harvest_configuration.try(:target_entity)

          has_existing_parent? ? existing_parent : default_target_entity
        else
          harvest_entity.parent.entity
        end
      end

      # @param [HasHarvestModificationStatus] entity
      def modifiable?(entity)
        entity.new_record? || entity.pristine_for_harvest?
      end

      # @return [void]
      def maybe_apply_data!
        return unless modifiable?(actual_entity)

        @modified = true

        actual_entity.harvest_modification_status = "pristine"

        actual_entity.schema_version = harvest_entity.schema_version

        actual_entity.assign_attributes harvest_entity.attributes_to_assign

        # Saving the entity should work at this point, and we need it to be persisted now.
        actual_entity.save!

        actual_entity.patch_properties(harvest_entity.extracted_properties) do |m|
          m.success do
            # Re-save to reload after applying all properties.
            actual_entity.save!
          end

          m.failure(:invalid_values) do |_, result|
            log_validation_failures!(result)
          end

          m.failure do |*error|
            # :nocov:
            logger.fatal("could not write properties for unknown reason", tags: %w[unknown_property_write_failure], error:)
            # :nocov:
          end
        end

        return
      end

      # @param [Dry::Validation::Result] result
      # @return [void]
      def log_validation_failures!(result)
        result.errors.each do |error|
          log_validation_failure! error
        end
      end

      # @param [Dry::Validation::Message] error
      # @return [void]
      def log_validation_failure!(error)
        human_path = error.path.map { "[#{_1.inspect}]" }.join

        logger.error "failed to write `entity#{human_path}`: #{error.text}", tags: ["invalid_property", human_path], path: error.path
      end

      # @return [void]
      def refresh_orderings_asynchronously!
        Schemas::Orderings.with_asynchronous_refresh do
          yield
        end
      end

      # @return [void]
      def track_upsert_duration!
        upsert_duration = AbsoluteTime.realtime do
          yield
        end

        # :nocov:
        return unless link.present? && modified?
        # :nocov:

        link.update_columns(upsert_duration:)
      end
    end
  end
end

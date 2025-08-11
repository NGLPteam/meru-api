# frozen_string_literal: true

module Harvesting
  module Records
    # @see Harvesting::Records::ExtractEntities
    class EntitiesExtractor < Support::HookBased::Actor
      include Harvesting::Attempts::RecordLinks::Loading
      include Harvesting::Middleware::ProvidesHarvestData
      include Harvesting::WithLogger
      include Dry::Effects::Handler.Interrupt(:skip_record, as: :catch_record_skip)
      include Dry::Effects.Interrupt(:skip_record)
      include Dry::Effects::Handler.State(:extracted_contribution_ids)
      include Dry::Effects::Handler.State(:extracted_contributor_ids)
      include Dry::Initializer[undefined: false].define -> do
        param :harvest_record, Harvesting::Types::Record
      end

      include MeruAPI::Deps[
        find_existing_collection: "harvesting.utility.find_existing_collection",
        upsert_contribution_proxies: "harvesting.metadata.upsert_contribution_proxies",
      ]

      delegate :harvest_configuration, :harvest_source, to: :harvest_record

      delegate :harvest_mapping, :harvest_attempt, to: :harvest_configuration, allow_nil: true

      standard_execution!

      # @return [<String>]
      attr_reader :existing_contributor_ids

      # @return [<String>]
      attr_reader :extracted_contribution_ids

      # @return [<String>]
      attr_reader :extracted_contributor_ids

      # @return [<String>]
      attr_reader :extracted_entity_ids

      # @return [Harvesting::Extraction::Context]
      attr_reader :extraction_context

      # @return [HarvestAttemptRecordLink]
      attr_reader :link

      # @return [Harvesting::Metadata::Context]
      attr_reader :metadata_context

      # @return [HarvestMetadataFormat]
      attr_reader :metadata_format

      # @return [Harvesting::Protocols::Context]
      attr_reader :protocol

      # @return [Harvesting::Extraction::RenderContext]
      attr_reader :render_context

      delegate :metadata_mappings, :use_metadata_mappings?, to: :extraction_context

      around_execute :provide_harvest_configuration!
      around_execute :provide_harvest_source!
      around_execute :provide_harvest_mapping!
      around_execute :provide_harvest_attempt!
      around_execute :provide_harvest_record!
      around_execute :provide_metadata_format!

      # @return [Dry::Monads::Success(HarvestRecord)]
      def call
        yield set_up!

        run_callbacks :execute do
          yield prepare!

          yield extract!

          yield prune!

          yield mark_active!

          yield update_entity_count!
        end

        link.try(:transition_to, "extracted")

        harvest_record.reload

        Success harvest_record
      end

      wrapped_hook! def prepare
        @metadata_context = harvest_record.build_metadata_context

        @link = load_harvest_attempt_record_link

        @render_context = harvest_record.build_render_context(metadata_context:, extraction_context:)

        @structs = []

        @entities = []

        @existing_contributor_ids = harvest_record.harvest_contributor_ids
        @extracted_contribution_ids = []
        @extracted_contributor_ids = []
        @extracted_entity_ids = []

        super
      end

      wrapped_hook! def extract
        @structs.concat render_context.render_entity_structs

        # :nocov:
        logger.warn("no entities extracted") if @structs.blank?
        # :nocov:

        @structs.each do |root_struct|
          yield upsert_struct root_struct
        end
      rescue Harvesting::Error => e
        logger.fatal e.message, tag: %i[entity_extraction_failure], exception_klass: e.class.name, backtrace: e.backtrace

        skip!(e.message, code: :extraction_exception)
      else
        super
      end

      wrapped_hook! def prune
        HarvestContribution.by_record(harvest_record).where.not(id: extracted_contribution_ids).destroy_all

        orphaned_contributor_ids = existing_contributor_ids - extracted_contributor_ids

        HarvestContributor.sans_contributions.where(id: orphaned_contributor_ids).destroy_all

        harvest_record.harvest_entities.where.not(id: extracted_entity_ids).destroy_all

        super
      end

      wrapped_hook! def mark_active
        harvest_record.update_column :status, :active

        super
      end

      wrapped_hook! def update_entity_count
        HarvestRecord.where(id: harvest_record.id).update_all(entity_count: HarvestEntity.where(harvest_record_id: harvest_record.id).count)

        super
      end

      around_execute :watch_extraction!
      around_extract :watch_contributions!
      around_extract :watch_contributors!
      around_extract :track_extraction_duration!

      private

      # @param [HarvestEntity] harvest_entity
      # @return [void]
      def connect_attempt!(harvest_entity)
        # :nocov:
        return if harvest_attempt.blank?
        # :nocov:

        harvest_attempt.connect_entity! harvest_entity
      end

      # @param [Harvesting::Entities::Struct] entity_struct
      # @param [HarvestEntity] parent
      # @return [Dry::Monads::Success(HarvestEntity)]
      do_for! def upsert_struct(entity_struct, parent: nil)
        identifier = entity_struct.identifier

        unless entity_struct.valid?
          entity_struct.errors.full_messages.each do |message|
            logger.error("Cannot extract entity: #{message}", identifier:)
          end

          return Success(nil)
        end

        existing_parent = maybe_match_existing_parent(entity_struct)

        entity = find_or_create_entity(identifier, parent:, existing_parent:)

        entity_struct.assign_to! entity

        entity.save!

        connect_attempt! entity

        extracted_entity_ids << entity.id

        @entities << entity

        yield upsert_contribution_proxies.(entity, entity_struct.contributions)

        entity_struct.children.each do |child|
          upsert_struct child, parent: entity
        end

        Success entity
      rescue ActiveRecord::RecordInvalid => e
        logger.fatal "Failed to upsert entity: #{e.message}"

        skip_and_halt! "Could not upsert entity"
      end

      # @param [String, nil] identifier
      # @return [Collection, nil]
      def existing_collection_from!(identifier)
        find_existing_collection.(identifier)
      rescue ActiveRecord::RecordNotFound
        skip_and_halt! "Expected existing collection with identifier: #{identifier}", code: :unknown_parent
      rescue LimitToOne::TooManyMatches
        skip_and_halt! "Identifier is not globally unique: #{identifier}", code: :unmatchable_parent
      end

      # @param [Harvesting::Entities::Struct] entity_struct
      # @return [HarvestTarget]
      def maybe_match_existing_parent(entity_struct)
        return unless use_metadata_mappings? && entity_struct.has_metadata_mappings_match?

        match = entity_struct.metadata_mappings_match.symbolize_keys

        metadata_mappings.matching_one!(**match)
      rescue ActiveRecord::RecordNotFound
        code = "metadata_mapping_not_found"

        metadata = {
          match:,
        }

        logger.error "Could not find metadata mapping with #{match.inspect}"

        skip_and_halt!("no metadata mappings found", code:, metadata:)
      rescue LimitToOne::TooManyMatches
        code = "metadata_mapping_too_many_found"

        metadata = {
          match:,
        }

        logger.error "Too many metadata mapping results with #{match.inspect}"

        skip_and_halt!("too many metadata mappings match", code:, metadata:)
      end

      # @param [String] identifier
      # @param [HarvestEntity, nil] parent
      # @return [HarvestEntity]
      def find_or_create_entity(identifier, parent: nil, existing_parent: nil)
        entity = harvest_record.harvest_entities.by_identifier(identifier).first_or_initialize

        entity.parent = parent
        entity.existing_parent = existing_parent

        return entity
      end

      # @return [void]
      def watch_contributions!
        ids, _ = with_extracted_contribution_ids([]) do
          yield
        end

        @extracted_contribution_ids.concat(ids)
      end

      # @return [void]
      def watch_contributors!
        ids, _ = with_extracted_contributor_ids([]) do
          yield
        end

        @extracted_contributor_ids.concat(ids)
      end

      # @return [Dry::Monads::Success(void)]
      def set_up!
        # :nocov:
        return Failure[:missing_harvest_configuration] if harvest_record.harvest_configuration.blank?
        # :nocov:

        @extraction_context = harvest_configuration.build_extraction_context

        @metadata_format = extraction_context.metadata_format

        @protocol = harvest_record.build_protocol_context

        Success()
      end

      # Non-interrupt version.
      #
      # @see Harvesting::Records::Skipped.because
      # @param [String] reason
      # @param [Hash] options
      # @return [void]
      def skip!(reason, **options)
        skipped = Harvesting::Records::Skipped.because reason, **options

        track_skip! skipped
      end

      # Interrupt version.
      #
      # @see Harvesting::Records::Skipped.because
      # @param [String] reason
      # @param [Hash] options
      # @return [void]
      def skip_and_halt!(reason, **options)
        skipped = Harvesting::Records::Skipped.because reason, **options

        skip_record skipped
      end

      # @return [void]
      def track_extraction_duration!
        extraction_duration = AbsoluteTime.realtime do
          yield
        end

        # :nocov:
        return unless link.present?
        # :nocov:

        link.update_columns(extraction_duration:)
      end

      # @param [Harvesting::Records::Skipped] skipped
      # @return [void]
      def track_skip!(skipped)
        columns = { status: :skipped, skipped:, entity_count: 0 }

        harvest_record.update_columns columns

        harvest_record.harvest_entities.delete_all

        harvest_record.reload

        Success()
      end

      # @return [void]
      def watch_extraction!
        skipped, result = catch_record_skip do
          yield
        end

        track_skip!(result) if skipped
      end
    end
  end
end

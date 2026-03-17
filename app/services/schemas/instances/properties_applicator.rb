# frozen_string_literal: true

module Schemas
  module Instances
    # Validates and saves schema values from any source to an entity.
    #
    # To patch a partial set of properties, use {Schemas::Instances::PatchProperties}.
    #
    # @see Schemas::Instances::Apply
    class PropertiesApplicator < Support::HookBased::Actor
      include Dry::Initializer[undefined: false].define -> do
        param :entity, ::Entities::Types::Entity

        param :values, Types::Coercible::Hash, as: :raw_values
      end

      alias instance entity

      standard_execution!

      around_execute :lock_entity!

      # @return [Schemas::Properties::Context, nil]
      attr_reader :context

      # @return [Schema::Instances::PropertySet]
      attr_reader :properties

      # @return [SchemaVersion]
      attr_reader :schema_version

      # The validated values, ready to be written.
      #
      # @return [Hash]
      attr_reader :values

      # @return [Dry::Monads::Success(HierarchicalEntity)]
      def call
        run_callbacks :execute do
          yield prepare!

          yield organize_property_values!

          yield write_all_values!

          yield denormalize_values!

          yield reload_references!
        end

        yield entity.invalidate_all_layouts unless entity.in_graphql_mutation?

        Success entity
      end

      wrapped_hook! def prepare
        @context = @values = nil

        @properties = entity.properties.deep_dup

        @schema_version = entity.schema_version

        @values = yield MeruAPI::Container["schemas.properties.validate"].(schema_version, raw_values, instance:)

        enforce_schema_header!

        super
      end

      wrapped_hook! def organize_property_values
        write_context = Schemas::Properties::WriteContext.new entity, schema_version, values

        schema_version.configuration.properties.each do |property|
          yield property.write_values_within! write_context
        end

        @context = write_context.finalize

        super
      end

      wrapped_hook! def write_all_values
        write_values!
        write_collected_references!
        write_scalar_references!

        yield entity.write_schematic_texts(context:)

        super
      end

      wrapped_hook! def denormalize_values
        yield entity.extract_orderable_properties(context:)

        yield entity.extract_searchable_properties(context:)

        yield entity.extract_composed_text

        super
      end

      wrapped_hook! def reload_references
        entity.schematic_collected_references.reload
        entity.schematic_scalar_references.reload
        entity.schematic_texts.reload

        super
      end

      private

      # Ensure the property set schema header is correct
      # @todo This should check that we are not overwriting a different version once
      #   we support more diverse schema declarations.
      # @return [void]
      def enforce_schema_header!
        properties.schema = schema_version.to_header
      end

      # @return [void]
      def lock_entity!
        entity.with_lock do
          entity.with_active_mutation! do
            yield
          end
        end
      end

      # Writes the property values to the entity and persists
      # it with `update_columns` to avoid callbacks. This is
      # because the property applicator can be called during
      # entity maintenance if `pending_properties` are set.
      #
      # @return [void]
      def write_values!
        properties.values = context.values

        entity.update_columns(properties:, updated_at: Time.current)
      end

      # Write collected references (e.g. an array of entities referenced by a property) to the database.
      #
      # @return [void]
      def write_collected_references!
        context.collected_references.each do |full_path, referents|
          MeruAPI::Container["schemas.references.write_collected_references"].call(entity, full_path, referents)
        end
      end

      # Write scalar references (e.g. a single entity referenced by a property) to the database.
      #
      # @return [void]
      def write_scalar_references!
        context.scalar_references.each do |full_path, referent|
          MeruAPI::Container["schemas.references.write_scalar_reference"].call(entity, full_path, referent)
        end
      end
    end
  end
end

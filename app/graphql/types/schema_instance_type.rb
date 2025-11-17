# frozen_string_literal: true

module Types
  module SchemaInstanceType
    include Types::BaseInterface
    include Types::HasSchemaPropertiesType

    description <<~TEXT
    Being an instance that implements a schema version with strongly-typed properties.
    Overlaps with Entity, but intended for focused access to just the properties
    and the necessary context.
    TEXT

    field :available_entities_for, ["Types::EntitySelectOptionType", { null: false }], null: false do
      description <<~TEXT
      Expose all available entities for this schema property.
      TEXT

      argument :full_path, String, required: true do
        description <<~TEXT
        The full path to the schema property. Please note, paths are snake_case, not camelCase.
        TEXT
      end
    end

    field :schema_instance_context, "Types::SchemaInstanceContextType", null: false do
      description <<~TEXT
      The context for our schema instance. Includes form values and necessary referents.
      TEXT
    end

    field :schema_property, "::Types::Schematic::SchemaPropertyType", null: true do
      description <<~TEXT
      Read a single schema property by its full path.
      TEXT

      argument :full_path, String, required: true do
        description <<~TEXT
        The full path to the schema property. Please note, paths are snake_case, not camelCase.
        TEXT
      end
    end

    def available_entities_for(full_path:)
      with_schema_associations_loaded.then do |(context, *)|
        object.read_property(full_path, context:).bind do |prop|
          prop.available_entities
        end.value_or([])
      end
    end

    def schema_instance_context
      if MeruConfig.experimental_dataloader?
        dataloader.with(Sources::SchemaPropertyContext).load(object)
      else
        Loaders::SchemaPropertyContextLoader.for(object.class).load(object)
      end
    end

    # @see Schemas::Instances::ReadProperties
    # @see HasSchemaDefinition#read_properties
    def schema_properties
      with_schema_associations_loaded.then do |(context, *)|
        object.read_properties(context:).value_or([])
      end
    end

    # @see Schemas::Instances::ReadProperty
    # @see HasSchemaDefinition#read_property
    def schema_property(full_path:)
      with_schema_associations_loaded.then do |(context, *)|
        object.read_property(full_path, context:).value_or(nil)
      end
    end

    load_association! :schematic_collected_references
    load_association! :schematic_scalar_references
    load_association! :schematic_texts

    private

    def with_schema_associations_loaded
      associations = [
        schema_instance_context,
        schematic_collected_references,
        schematic_scalar_references,
        schematic_texts,
      ]

      maybe_await(associations)
    end
  end
end

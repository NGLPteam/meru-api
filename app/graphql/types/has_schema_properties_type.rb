# frozen_string_literal: true

module Types
  module HasSchemaPropertiesType
    include Types::BaseInterface

    field :schema_properties, ["::Types::Schematic::SchemaPropertyType", { null: false }], null: false do
      description <<~TEXT
      A list of schema properties associated with this instance or version.
      TEXT
    end

    # @see Schemas::Instances::ReadProperties
    def schema_properties
      object.read_properties.value_or([])
    end
  end
end

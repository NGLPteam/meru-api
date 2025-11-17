# frozen_string_literal: true

module Types
  module Schematic
    module SchemaPropertyType
      include Types::BaseInterface

      description <<~TEXT
      A property on a `SchemaInstance`.
      TEXT

      field :full_path, String, null: false do
        description <<~TEXT
        The full path that represents the property on the schema instance. It is guaranteed
        to be unique for the instance, and can be used to grab a property directly, as well as
        facilitating schema validation and errors within the admin application's forms.
        TEXT
      end

      field :path, String, null: false do
        description <<~TEXT
        The "short" path for the property. For properties nested within a group, this can
        be considered the name of the property without the group's prefix.
        TEXT
      end

      field :description, String, null: true do
        description <<~TEXT
        A human-readable description for the property. It should describe the purpose of the
        property as well as some details about the types of values it looks for.

        It can be rendered as help text, hints, etc.
        TEXT
      end

      field :kind, "Types::SchemaPropertyKindType", null: false do
        description <<~TEXT
        Provided for introspection. This describes the underlying structure of the data type.
        TEXT
      end

      field :type, "Types::SchemaPropertyTypeType", null: false do
        description <<~TEXT
        Provided for introspection. This represents the actual data type this property
        uses.

        Rendering in the frontend should rely primarily on the `AnySchemaProperty` and
        `AnyScalarProperty` unions (in that order)`, rather than relying on this value,
        since the actual implementations of these properties differ in the GraphQL types
        associated with their values.
        TEXT
      end

      field :array, Boolean, null: false, method: :array? do
        description <<~TEXT
        Provided for introspection. This describes whether or not the property's value
        comes in an array rather than representing a discrete piece of information.

        See `AssetsProperty`, `ContributorsProperty`, `MultiselectProperty`, and `TagsProperty`
        for examples.
        TEXT
      end

      field :orderable, Boolean, null: false, method: :orderable? do
        description <<~TEXT
        Provided for introspection. Whether this property can be used to order entities.
        For certain data types, there's no sensible way to order properties.
        TEXT
      end
    end
  end
end

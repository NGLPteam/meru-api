# frozen_string_literal: true

module Types
  module Schematic
    module ScalarPropertyType
      include Types::BaseInterface

      implements ::Types::Schematic::SchemaPropertyType

      field :label, String, null: false do
        description <<~TEXT
        A human-readable label for the schema property.
        TEXT
      end

      field :required, Boolean, null: false do
        description <<~TEXT
        Whether or not this property is required in order for the schema instance
        to be considered valid.

        Note: invalid data provided to a schema property will still invalidate
        the instance as a whole—the required trait only determines whether a value
        **must** be set.
        TEXT
      end

      field :function, Types::SchemaPropertyFunctionType, null: false do
        description <<~TEXT
        The purpose or intent of this property relative to its entity, parents, and others.
        TEXT
      end

      field :is_wide, Boolean, null: false, method: :wide? do
        description <<~TEXT
        Whether to render a field as "wide" (two columns) in the form.
        This is intended to help structure forms logically, as well as
        provide ample space for certain types of data input, particularly
        full-text, markdown, and other such complex fields.
        TEXT
      end

      def function
        object.function.presence || "unspecified"
      end

      def label
        object.label.presence || object.path.titleize
      end

      def required
        object.required.present?
      end
    end
  end
end

# frozen_string_literal: true

module Types
  module LayoutDefinitionType
    include Types::BaseInterface

    description <<~TEXT
    Entities within the system have layouts associated with their schema,
    that can eventually be overridden for more custom approaches.

    This interface defines the *definition* for one such layout, while any
    given entity will also have its own LayoutInstance.
    TEXT

    field :layout_kind, Types::LayoutKindType, null: false

    def templates
      all_templates = object.template_definition_names.map { __send__(_1) }

      maybe_await(all_templates).then do
        object.template_definitions
      end
    end
  end
end

# frozen_string_literal: true

module Types
  module LayoutInstanceType
    include Types::BaseInterface

    description <<~TEXT
    Entities within the system have layouts associated with their schema,
    that can eventually be overridden for more custom approaches.

    This interface defines the *instance* for one such layout and entity,
    derived from an associated `LayoutDefinition`.
    TEXT

    implements Types::RenderableType

    field :layout_kind, Types::LayoutKindType, null: false

    field :entity, Types::AnyEntityType, null: false do
      description <<~TEXT
      The associated entity for this layout instance.
      TEXT
    end

    load_association! :entity

    load_association! :layout_definition

    def templates
      all_templates = object.template_instance_names.map { __send__(_1) }

      Promise.all(all_templates).then do
        object.template_instances
      end
    end
  end
end

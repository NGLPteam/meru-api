# frozen_string_literal: true

module Types
  module TemplateInstanceType
    include Types::BaseInterface

    description <<~TEXT
    Entities within the system have templates associated with schema-specific layouts,
    that can be overridden within the hierarchy for more custom approaches.

    This interface defines the *instance* for one such template and entity,
    derived from an associated `TemplateDefinition`.
    TEXT

    implements Types::RenderableType

    field :entity, Types::EntityType, null: false do
      description <<~TEXT
      The associated entity for this template instance.
      TEXT
    end

    field :layout_kind, Types::LayoutKindType, null: false

    field :template_kind, Types::TemplateKindType, null: false

    field :all_slots_empty, Boolean, null: false do
      description <<~TEXT
      Whether all slots in this template are empty.
      TEXT
    end

    field :hidden, Boolean, null: false do
      description <<~TEXT
      Whether this template instance should be hidden based on some logic.

      At present, this only occurs if certain slots are empty.
      TEXT
    end

    field :prev_siblings, [Types::TemplateInstanceSiblingType, { null: false }], null: false do
      description <<~TEXT
      Return all preceding siblings to the current template in order of proximity.

      If a template is at position 3 of 5, then this field will return position 2 and 1 in that order.
      TEXT
    end

    field :next_siblings, [Types::TemplateInstanceSiblingType, { null: false }], null: false do
      description <<~TEXT
      Return all preceding siblings to the current template in order of proximity.

      If a template is at position 3 of 5, then this field will return position 4 and 5 in that order.
      TEXT
    end

    load_association! :entity

    load_association! :prev_siblings

    load_association! :next_siblings
  end
end

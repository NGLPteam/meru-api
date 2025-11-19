# frozen_string_literal: true

module Types
  # @see Templates::EntityList
  # @see Templates::Definitions::HasEntityList
  # @see Templates::Instances::HasEntityList
  # @see Types::TemplateHasEntityListType
  class TemplateEntityListType < Types::BaseObject
    description <<~TEXT
    Some template instances return an ordered list of entities to render
    within as part of their content.

    This provides access to that list, as well as a shortcut to each entity's
    associated `ListItemLayoutInstance`.

    **note** It's possible that entities could match the parameters of the list
    but be skipped because they have no layouts (yet). This is intentional behavior,
    and subsequent fetches should see the list populated as soon as the descendant
    entities layouts have rendered.
    TEXT

    field :count, Int, null: false do
      description <<~TEXT
      The size of the list.
      TEXT
    end

    field :empty, Boolean, null: false do
      description <<~TEXT
      Whether the list is empty, provided for easier filtering and render-skipping.
      TEXT
    end

    field :entities, ["::Types::EntityType", { null: false }], null: false, method: :valid_entities do
      description <<~TEXT
      The actual entity records within this list.

      The order is deterministic.
      TEXT
    end

    field :fallback, Boolean, null: false do
      description <<~TEXT
      Whether the entity selection tried to use the fallback selection mode.

      When true, the resulting list is fallback. It can still be empty.
      TEXT
    end

    field :flat_depth, Boolean, null: false do
      description <<~TEXT
      Whether there is any variation in hierarchical depth within the list of entities.
      TEXT
    end

    field :list_item_layouts, ["::Types::Layouts::ListItemLayoutInstanceType", { null: false }], null: false do
      description <<~TEXT
      A shortcut to access the list item layouts for each entity in `entities`.

      The order is deterministic.

      See `ListItemLayoutInstance`.
      TEXT
    end

    field :maximum_depth, Integer, null: true do
      description <<~TEXT
      The maximum hierarchical depth for the entities in the list (if known).
      TEXT
    end

    field :minimum_depth, Integer, null: true do
      description <<~TEXT
      The minimum hierarchical depth for the entities in the list (if known).
      TEXT
    end

    load_association! :entities

    load_association! :list_item_layout_instances, as: :list_item_layouts
  end
end

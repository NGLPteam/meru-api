# frozen_string_literal: true

module Templates
  # @see Templates::CachedEntityListItem
  # @see Templates::EntityList
  # @see Templates::Instances::EntityListCacher
  class CachedEntityList < ApplicationRecord
    include HasEphemeralSystemSlug
    include TimestampScopes

    belongs_to :template_instance, polymorphic: true
    belongs_to :entity, polymorphic: true

    has_many :cached_entity_list_items, -> { in_default_order }, class_name: "Templates::CachedEntityListItem", inverse_of: :cached_entity_list, dependent: :delete_all

    has_many :entities, through: :cached_entity_list_items, source: :entity
    has_many :list_item_layout_instances, through: :cached_entity_list_items, source: :list_item_layout_instance

    # @return [Integer]
    def prune_items!
      cached_entity_list_items.beyond(count).delete_all
    end
  end
end

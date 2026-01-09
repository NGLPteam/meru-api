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

    has_many :cached_entity_list_items, -> { in_default_order.includes(:entity) }, class_name: "Templates::CachedEntityListItem",
      inverse_of: :cached_entity_list, dependent: :delete_all

    has_many :list_item_layout_instances, through: :cached_entity_list_items, source: :list_item_layout_instance

    # @note Cannot eager-load because of polymorphic associations.
    def entities
      # :nocov:
      cached_entity_list_items.map(&:entity)
      # :nocov:
    end

    # @return [Integer]
    def prune_items!
      cached_entity_list_items.beyond(count).delete_all
    end

    # @see Templates::EntityLists::RefreshCached
    # @see Templates::EntityLists::CachedRefresher
    monadic_operation! def refresh
      call_operation("templates.entity_lists.refresh_cached", self)
    end
  end
end

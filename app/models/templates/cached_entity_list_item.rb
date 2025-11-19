# frozen_string_literal: true

module Templates
  # @see Templates::CachedEntityList
  # @see Templates::EntityList
  # @see Templates::Instances::EntityListCacher
  class CachedEntityListItem < ApplicationRecord
    include HasEphemeralSystemSlug
    include TimestampScopes

    belongs_to :cached_entity_list, class_name: "Templates::CachedEntityList", inverse_of: :cached_entity_list_items
    belongs_to :entity, polymorphic: true
    belongs_to :list_item_layout_instance, class_name: "Layouts::ListItemInstance", inverse_of: :cached_entity_list_items
    belongs_to :schema_version, inverse_of: :cached_entity_list_items

    scope :beyond, ->(count) { reorder(nil).where(arel_beyond(count)) }

    scope :in_default_order, -> { order(position: :asc) }

    class << self
      # @param [Integer] count
      # @return [Arel::Nodes::GreaterThan]
      def arel_beyond(count)
        arel_table[:position].gt(count)
      end
    end
  end
end

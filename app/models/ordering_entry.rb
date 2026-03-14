# frozen_string_literal: true

# A join model connecting a sorted {HierarchicalEntity entity} with an {Ordering}.
class OrderingEntry < ApplicationRecord
  include EntityAdjacent
  include TimestampScopes

  ENTITY_TUPLE = %i[entity_type entity_id].freeze

  belongs_to :ordering, inverse_of: :ordering_entries

  has_many :ordering_entry_ancestor_links, -> { in_order },
    foreign_key: :child_id,
    inverse_of: :child, dependent: :delete_all

  has_many :ordering_entry_descendant_links, -> { in_descendant_order },
    class_name: "OrderingEntryAncestorLink",
    foreign_key: :ancestor_id,
    inverse_of: :ancestor,
    dependent: :delete_all

  has_many :ancestors, through: :ordering_entry_ancestor_links

  has_many :descendants, through: :ordering_entry_descendant_links, source: :child

  has_many :ordering_template_instances,
    class_name: "Templates::OrderingInstance",
    inverse_of: :ordering_entry,
    primary_key: %i[ordering_id id],
    foreign_key: %i[ordering_id ordering_entry_id],
    dependent: :nullify

  has_one :ordering_entry_sibling_link,
    primary_key: %i[ordering_id id],
    foreign_key: %i[ordering_id sibling_id],
    dependent: :delete, inverse_of: :sibling

  has_one :prev_sibling, through: :ordering_entry_sibling_link, source: :prev
  has_one :next_sibling, through: :ordering_entry_sibling_link, source: :next

  belongs_to :entity, polymorphic: true, inverse_of: :ordering_entries

  belongs_to_readonly :normalized_entity, class_name: "Entity", primary_key: ENTITY_TUPLE, foreign_key: ENTITY_TUPLE

  has_many_readonly :named_variable_dates, primary_key: ENTITY_TUPLE, foreign_key: ENTITY_TUPLE

  scope :in_default_order, -> { reorder(position: :asc) }
  scope :in_inverse_order, -> { reorder(inverse_position: :asc) }

  scope :by_ordering, ->(ordering) { where(ordering:) }
  scope :by_entity, ->(entity) { where(entity:) }

  class << self
    # @param [HierarchicalEntity] entity
    # @return [ActiveRecord::Relation<OrderingEntry>]
    def linking_to(entity)
      where(entity_type: "EntityLink", entity_id: entity.incoming_links.select(:id))
    end

    # @param [<Ordering>] orderings
    # @return [{ String => Integer }]
    def visible_count_for(orderings)
      currently_visible.by_ordering(orderings).group(:ordering_id).count
    end
  end
end

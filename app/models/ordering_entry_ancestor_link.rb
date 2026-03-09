# frozen_string_literal: true

# A join model that connects a leaf {OrderingEntry} with 1+ parent entries
# when its associated {Ordering} is a tree.
class OrderingEntryAncestorLink < ApplicationRecord
  include GenericInaccessible
  include TimestampScopes

  self.primary_key = %i[ordering_id id]

  belongs_to :ordering, inverse_of: :ordering_entry_ancestor_links

  belongs_to :child, primary_key: %i[ordering_id id], foreign_key: %i[ordering_id child_id],
    class_name: "OrderingEntry", inverse_of: :ordering_entry_ancestor_links

  belongs_to :ancestor, primary_key: %i[ordering_id id], foreign_key: %i[ordering_id ancestor_id],
    class_name: "OrderingEntry", inverse_of: :ordering_entry_descendant_links

  scope :in_order, -> { order(inverse_depth: :desc) }

  scope :in_descendant_order, -> { reorder(inverse_depth: :asc, position: :asc) }
end

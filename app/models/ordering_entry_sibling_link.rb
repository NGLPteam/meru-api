# frozen_string_literal: true

# A denormalized view that's able to grab the prev & next entries for any given
# {OrderingEntry}, if one exists.
class OrderingEntrySiblingLink < ApplicationRecord
  include GenericInaccessible
  include TimestampScopes

  self.primary_key = %i[ordering_id sibling_id]

  belongs_to :ordering, inverse_of: :ordering_entry_sibling_links

  belongs_to :sibling, class_name: "OrderingEntry", primary_key: %i[ordering_id id], foreign_key: %i[ordering_id sibling_id], inverse_of: :ordering_entry_sibling_link

  belongs_to_readonly :prev, class_name: "OrderingEntry", primary_key: %i[ordering_id id], foreign_key: %i[ordering_id prev_id]
  belongs_to_readonly :next, class_name: "OrderingEntry", primary_key: %i[ordering_id id], foreign_key: %i[ordering_id next_id]
end

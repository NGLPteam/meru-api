# frozen_string_literal: true

# A view used to calculate total and visible entry counts for an {Ordering}.
# These counts are denormalized onto the {Ordering} model.
class OrderingEntryCount < ApplicationRecord
  include View

  self.primary_key = :ordering_id

  belongs_to_readonly :ordering, inverse_of: :ordering_entry_count
end

# frozen_string_literal: true

# A view used to calculate the published date range for an {Ordering}.
# This data is denormalized onto the {Ordering} model.
class OrderingDateRange < ApplicationRecord
  include View

  self.primary_key = :ordering_id

  belongs_to_readonly :ordering, inverse_of: :ordering_date_range
end

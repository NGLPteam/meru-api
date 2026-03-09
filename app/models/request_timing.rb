# frozen_string_literal: true

class RequestTiming < ApplicationRecord
  include GenericInaccessible
  include HasEphemeralSystemSlug
  include TimestampScopes

  belongs_to :request_query, inverse_of: :request_timings

  validates :duration, presence: true
end

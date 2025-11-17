# frozen_string_literal: true

# A step in the processing of a GraphQL request, recorded for performance monitoring.
class RequestStep < ApplicationRecord
  include HasEphemeralSystemSlug
  include TimestampScopes

  belongs_to :request_query, inverse_of: :request_steps
end

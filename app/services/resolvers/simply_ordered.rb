# frozen_string_literal: true

module Resolvers
  # For resolvers that don't have their own order ::Types, fall back to a generic that
  # merely sorts by `created_at` in ascending or descending order. It defaults to `recent`.
  #
  # @see ::Types::SimpleOrderType
  module SimplyOrdered
    extend ActiveSupport::Concern

    included do
      orders_with! ::Types::SimpleOrderType, default: "RECENT"
    end
  end
end

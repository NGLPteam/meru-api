# frozen_string_literal: true

module Resolvers
  # A concern for resolvers that order {DepositorRequest} with {::Types::DepositorRequestOrderType}.
  module OrderedAsDepositorRequest
    extend ActiveSupport::Concern

    include ::Resolvers::AbstractOrdering

    included do
      orders_with! ::Types::DepositorRequestOrderType, default: "DEFAULT"
    end
  end
end

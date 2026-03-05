# frozen_string_literal: true

module Resolvers
  # A concern for resolvers that order {Ordering} models with {Types::OrderingOrderType}.
  module OrderedAsOrdering
    extend ActiveSupport::Concern

    included do
      option :order, type: ::Types::OrderingOrderType, default: "DETERMINISTIC"
    end

    def apply_order_with_deterministic(scope)
      scope.deterministically_ordered
    end

    def apply_order_with_recent(scope)
      scope.order(created_at: :desc)
    end

    def apply_order_with_oldest(scope)
      scope.order(created_at: :asc)
    end
  end
end

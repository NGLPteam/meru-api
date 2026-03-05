# frozen_string_literal: true

module Resolvers
  module PositionOrdered
    extend ActiveSupport::Concern

    included do
      orders_with! ::Types::PositionDirectionType, default: "ASCENDING"
    end

    def apply_order_with_ascending(scope)
      scope.reorder(position: :asc)
    end

    def apply_order_with_descending(scope)
      scope.reorder(position: :desc)
    end
  end
end

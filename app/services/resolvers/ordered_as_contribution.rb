# frozen_string_literal: true

module Resolvers
  # For resolvers that order {Contribution}s.
  module OrderedAsContribution
    extend ActiveSupport::Concern

    included do
      option :order, type: ::Types::ContributionOrderType, default: "TARGET_TITLE_ASCENDING"
    end

    def apply_order_with_recent(scope)
      scope.order(created_at: :desc)
    end

    def apply_order_with_oldest(scope)
      scope.order(created_at: :asc)
    end

    def apply_order_with_target_title_ascending(scope)
      scope.with_ordered_target_title(direction: :asc)
    end

    def apply_order_with_target_title_descending(scope)
      scope.with_ordered_target_title(direction: :desc)
    end
  end
end

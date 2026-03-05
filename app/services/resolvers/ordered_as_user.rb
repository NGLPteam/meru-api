# frozen_string_literal: true

module Resolvers
  # A concern for resolvers that order {User} ::Types with {Types::UserOrderType}.
  module OrderedAsUser
    extend ActiveSupport::Concern

    include ::Resolvers::AbstractOrdering

    included do
      orders_with! ::Types::UserOrderType, default: "RECENT"
    end

    order_pair! :email

    order_pair! :name

    def apply_order_with_admins_first(scope)
      scope.by_role_priority.lazily_order(:name, :asc)
    end

    def apply_order_with_admins_last(scope)
      scope.by_inverse_role_priority.lazily_order(:name, :desc)
    end

    def apply_order_with_admins_recent(scope)
      scope.by_role_priority.in_recent_order
    end

    def apply_order_with_admins_oldest(scope)
      scope.by_inverse_role_priority.in_oldest_order
    end
  end
end

# frozen_string_literal: true

module Resolvers
  # A concern for resolvers that order {Role} models with {Types::RoleOrderType}.
  #
  # @see ::Types::RoleOrderType
  module OrderedAsRole
    extend ActiveSupport::Concern

    included do
      option :order, type: ::Types::RoleOrderType, default: "DEFAULT"
    end

    def apply_order_with_default(scope)
      scope.in_default_order
    end

    def apply_order_with_recent(scope)
      apply_order_with_name_ascending scope.order(created_at: :desc)
    end

    def apply_order_with_oldest(scope)
      apply_order_with_name_ascending scope.order(created_at: :asc)
    end

    def apply_order_with_name_ascending(scope)
      scope.order(name: :asc)
    end

    def apply_order_with_name_descending(scope)
      scope.order(name: :desc)
    end
  end
end

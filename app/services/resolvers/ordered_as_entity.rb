# frozen_string_literal: true

module Resolvers
  module OrderedAsEntity
    extend ActiveSupport::Concern

    included do
      option :order, type: ::Types::EntityOrderType, default: "PUBLISHED_DESCENDING"
    end

    def apply_order_with_recent(scope)
      scope.order(created_at: :desc)
    end

    def apply_order_with_oldest(scope)
      scope.order(created_at: :asc)
    end

    def apply_order_with_position_ascending(scope)
      scope_wraps?(scope, Community) ? scope.order(position: :asc) : apply_order_with_recent(scope)
    end

    def apply_order_with_position_descending(scope)
      scope_wraps?(scope, Community) ? scope.order(position: :desc) : apply_order_with_oldest(scope)
    end

    def apply_order_with_published_ascending(scope)
      scope_wraps?(scope, Community) ? apply_order_with_oldest(scope) : scope.with_sorted_published_date(:asc)
    end

    def apply_order_with_published_descending(scope)
      scope_wraps?(scope, Community) ? apply_order_with_recent(scope) : scope.with_sorted_published_date(:desc)
    end

    def apply_order_with_title_ascending(scope)
      scope.order(title: :asc)
    end

    def apply_order_with_title_descending(scope)
      scope.order(title: :desc)
    end

    def apply_order_with_schema_name_ascending(scope)
      apply_order_with_title_ascending scope.with_schema_name_asc
    end

    def apply_order_with_schema_name_descending(scope)
      apply_order_with_title_ascending scope.with_schema_name_desc
    end
  end
end

# frozen_string_literal: true

module Resolvers
  module OrderedAsContributor
    extend ActiveSupport::Concern

    included do
      option :order, type: ::Types::ContributorOrderType, default: "NAME_ASCENDING"
    end

    def apply_order_with_recent(scope)
      scope.order(created_at: :desc)
    end

    def apply_order_with_oldest(scope)
      scope.order(created_at: :asc)
    end

    def apply_order_with_most_contributions(scope)
      apply_order_with_name_ascending scope.order(contribution_count: :desc)
    end

    def apply_order_with_least_contributions(scope)
      apply_order_with_name_ascending scope.order(contribution_count: :asc)
    end

    def apply_order_with_name_ascending(scope)
      scope.order(Contributor.arel_table[:sort_name].asc.nulls_last)
    end

    def apply_order_with_name_descending(scope)
      scope.order(Contributor.arel_table[:sort_name].desc.nulls_last)
    end

    def apply_order_with_affiliation_ascending(scope)
      apply_order_with_name_ascending scope.order(Contributor.arel_table[:affiliation].asc.nulls_last)
    end

    def apply_order_with_affiliation_descending(scope)
      apply_order_with_name_ascending scope.order(Contributor.arel_table[:affiliation].desc.nulls_last)
    end
  end
end

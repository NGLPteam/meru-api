# frozen_string_literal: true

module Resolvers
  class ContextualPermissionResolver < AbstractResolver
    include Resolvers::Enhancements::PageBasedPagination

    type ::Types::ContextualPermissionType.connection_type, null: false

    resolves_model! ::ContextualPermission, must_have_object: true

    option :order, type: ::Types::ContextualPermissionOrderType, default: "USER_NAME_ASC"

    def apply_order_with_recent(scope)
      scope.order(created_at: :desc)
    end

    def apply_order_with_oldest(scope)
      scope.order(created_at: :asc)
    end

    def apply_order_with_user_name_asc(scope)
      scope.joins(:user).order(User.arel_table[:name].asc)
    end

    def apply_order_with_user_name_desc(scope)
      scope.joins(:user).order(User.arel_table[:name].desc)
    end

    def resolve_default_scope
      super.preload(
        :roles, :user,
        access_grants: %i[user accessible subject item community collection role]
      )
    end
  end
end

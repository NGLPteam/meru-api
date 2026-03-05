# frozen_string_literal: true

module Access
  # A provisional {AccessGrant} that can be used for authorization checks.
  class Provisional < Support::FlexibleStruct
    include Support::Typing

    attribute? :current_user, ::Users::Types::Current

    attribute :entity, Access::Types::Entity

    attribute :role, Access::Types::Role

    attribute? :user, ::Users::Types::Current

    delegate :assignable_roles, to: :current_user

    alias accessible entity

    alias subject user

    def apply? = role.in?(assignable_roles)

    # @param [User] manager_user
    def has_manager?(manager_user) = ContextualSinglePermission.manages_access_for?(manager_user.id, entity)

    def policy_class = self.class.policy_class

    class << self
      def policy_class = AccessGrantPolicy
    end
  end
end

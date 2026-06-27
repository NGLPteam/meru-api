# frozen_string_literal: true

# This represents something to which an {AccessGrant} can assign a {Role}
# for a given {Accessible} entity, namely a {User}, but intended to allow
# expansion to {UserGroup} in the future.
#
# @see Access::Types::Subject
# @see Types::AccessGrantSubjectType
module AccessGrantSubject
  extend ActiveSupport::Concern
  extend DefinesMonadicOperation

  include AssociationHelpers

  included do
    has_many :access_grants, as: :subject, dependent: :destroy

    has_one_readonly :primary_role_assignment, as: :subject

    has_one_readonly :primary_role, through: :primary_role_assignment, source: :role

    has_many_readonly :assignable_roles, through: :primary_role
  end

  # @see Access::AssignGlobalPermissions
  # @return [Dry::Monads::Success(void)]
  monadic_operation! def assign_global_permissions
    call_operation("access.assign_global_permissions", self)
  end

  # @see Access::EnforceAssignments
  # @return [Dry::Monads::Success(void)]
  monadic_operation! def enforce_assignments
    call_operation("access.enforce_assignments", subject: self)
  end

  # @param [Hash] options
  # @see Access::PolymorphicGrant
  # @see Access::PolymorphicGranter
  # @return [Dry::Monads::Success(void)]
  monadic_operation! def polymorphic_grant(**options)
    call_operation("access.polymorphic_grant", self, **options)
  end

  # @api private
  # @note Used in testing to allow for easy granting of permissions
  # @param [FactoryBot::Evaluator] evaluator
  # @see #polymorphic_grant
  # @return [Dry::Monads::Success(void)]
  monadic_operation! def polymorphic_grant_from(evaluator)
    options = Role::POLYMORPHIC_GRANTABLE_KEYS.index_with do |key|
      evaluator.try(key) || []
    end

    polymorphic_grant(**options)
  end

  # @note This is used to determine the upload access permission for non-admins.
  # @see AccessGrant#with_asset_creation?
  # @see User#has_any_upload_access?
  def has_granted_asset_creation? = access_grants.with_asset_creation?
end

# frozen_string_literal: true

# This represents something to which an {AccessGrant} can assign a {Role}
# for a given {Accessible} entity, namely a {User}.
module AccessGrantSubject
  extend ActiveSupport::Concern

  include AssociationHelpers

  included do
    has_many :access_grants, as: :subject, dependent: :destroy

    has_one_readonly :primary_role_assignment, as: :subject

    has_one_readonly :primary_role, through: :primary_role_assignment, source: :role

    has_many_readonly :assignable_roles, through: :primary_role
  end

  # @see Access::AssignGlobalPermissions
  # @return [void]
  def assign_global_permissions!
    call_operation("access.assign_global_permissions", self).value!
  end

  def enforce_assignments!
    call_operation("access.enforce_assignments", subject: self).value!
  end

  def has_granted_asset_creation?
    access_grants.with_asset_creation?
  end
end

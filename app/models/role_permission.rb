# frozen_string_literal: true

# As one might expect, this connects a {Role} with the {Permission}s
# it can grant. It is used in particular to calculate {GrantedPermission}.
#
# @see Roles::CalculateRolePermissions
class RolePermission < ApplicationRecord
  include GenericAccessible
  include TimestampScopes

  belongs_to :permission, inverse_of: :role_permissions
  belongs_to :role, inverse_of: :role_permissions

  validates :permission_id, uniqueness: { scope: :role_id }
end

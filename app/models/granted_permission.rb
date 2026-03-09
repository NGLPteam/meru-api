# frozen_string_literal: true

# This is a table that combines and flattens elements from
# an {AccessGrant}, {Permission}, {Role}, {RolePermission},
# and {User}. It denormalizes the data contained in those
# models to more efficiently ascertain what a given user
# can do in the WDP.
#
# It is not accessed or created directly. It is used by
# both {ContextualSinglePermission} and {ContextualPermission},
# and created via {Access::CalculateGrantedPermission} and its
# related jobs.
class GrantedPermission < ApplicationRecord
  include GenericInaccessible
  include TimestampScopes

  belongs_to :access_grant, inverse_of: :granted_permissions
  belongs_to :permission, inverse_of: :granted_permissions
  belongs_to :user, inverse_of: :granted_permissions

  belongs_to :role, inverse_of: :granted_permissions
end

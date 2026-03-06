# frozen_string_literal: true

# The policy for a {Role}.
#
# Because of how this class works, a global admin does _not_ inherently have all
# permissions, and care must be taken to ensure we're checking this policy when
# mutating or assigning roles.
class RolePolicy < ApplicationPolicy
  always_readable!

  pre_check :deny_anonymous!, except: %i[read? show? index?]
  pre_check :deny_system!, except: %i[read? show? index? read_for_mutation? assign?]

  def create? = has_allowed_action? "roles.create"

  def update? = has_allowed_action? "roles.update"

  def destroy? = has_allowed_action? "roles.delete"

  # Whether the current role can be assigned by the current user.
  def assign?
    # Admin roles can never be assigned
    return false if reserved_assignment?

    record.in? user.assignable_roles
  end

  private

  # @return [void]
  def deny_system!
    deny! if record.for_system?
  end

  def reserved_assignment? = record.reserved?
end

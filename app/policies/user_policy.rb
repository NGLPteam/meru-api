# frozen_string_literal: true

# Presently, user creation and destruction is managed in Keycloak
# and cannot be handled directly in Meru. Permissions reflect this.
class UserPolicy < ApplicationPolicy
  def read?
    return true if record.anonymous? || record == user || has_allowed_action?("users.read") || has_any_access_management_permissions?

    super
  end

  def update?
    return true if authenticated_self_action?

    has_admin_or_allowed_action?("users.update") || super
  end

  def reset_password?
    return true if authenticated_self_action?

    has_admin_or_allowed_action?("users.update")
  end

  def revalidate_instance?
    user.has_global_admin_access?
  end

  def destroy?
    false
  end

  private

  def authenticated_self_action?
    return false if record.anonymous? || user.anonymous?

    record == user
  end

  class Scope < Scope
    def resolve
      return scope.all if admin_or_has_allowed_action?("users.read")

      return scope.none if user.anonymous?

      scope.where(id: user.id)
    end
  end
end

# frozen_string_literal: true

# Presently, user creation and destruction is managed in Keycloak
# and cannot be handled directly in Meru. Permissions reflect this.
class UserPolicy < ApplicationPolicy
  pre_check :allow_any_admin!, except: %i[create? destroy?]
  pre_check :deny_anonymous!, only: %i[update? reset_password? revalidate_instance?]
  pre_check :allow_authenticated_self_action!, only: %i[read? update? reset_password?]

  def read? = record.anonymous? || has_allowed_action?("users.read") || has_any_access_management_permissions?

  def update? = has_allowed_action?("users.update")

  def reset_password? = has_allowed_action?("users.update")

  def revalidate_instance? = has_admin?

  def destroy? = false

  private

  # @return [void]
  def allow_authenticated_self_action!
    allow! if authenticated_self_action?
  end

  def authenticated_self_action? = record == user

  def resolve_scope_for_authenticated(relation)
    if has_allowed_action?("users.read")
      relation.all
    else
      relation.where(id: user_id)
    end
  end

  def resolve_scope_for_anonymous(relation)
    relation.none
  end
end

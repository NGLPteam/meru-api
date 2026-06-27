# frozen_string_literal: true

# Presently, user creation and destruction is managed in Keycloak
# and cannot be handled directly in Meru. Permissions reflect this.
class UserPolicy < ApplicationPolicy
  admin_pre_check_exceptions! :access_admin?, :preview?, :create?, :destroy?, :receive_review_requests?, :revalidate_instance?, :claim_contributor?

  allows_any_admin!

  pre_check :deny_anonymous!, only: %i[access_admin? preview? read_privileged? update? receive_review_requests? reset_password? revalidate_instance? claim_contributor?]

  pre_check :allow_authenticated_self_action!, only: %i[read? show? read_privileged? update? reset_password?]

  pre_check :allow_reviewers!, only: %i[read? show?]

  def read? = authenticated?

  def read_privileged? = has_allowed_action?("users.read")

  def update? = has_allowed_action?("users.update")

  def access_admin? = record.has_allowed_action?("admin.access")

  # Really just {#access_admin?} for now, but exposed as an explicit permission for future expansion.
  def preview? = record.has_allowed_action?("admin.access")

  def claim_contributor? = record.authenticated? && record.may_claim_author?

  def manage_access? = has_any_access_management_permissions?

  def receive_review_requests? = admin_record? || record_is_reviewer?

  def reset_password? = has_allowed_action?("users.update")

  def revalidate_instance? = admin_record?

  def destroy? = false

  private

  # @return [void]
  def allow_authenticated_self_action!
    allow! if authenticated_self_action?
  end

  # @return [void]
  def allow_reviewers!
    allow! if authenticated? && record_is_reviewer?
  end

  def admin_record? = record.has_global_admin_access?

  def authenticated_self_action? = record == user

  def record_is_reviewer? = record.authenticated? && record.submission_target_reviewers.exists?

  def resolve_scope_for_authenticated(relation)
    if has_allowed_action?("users.read") || has_any_access_management_permissions?
      relation.all
    else
      relation.where(id: user_id)
    end
  end

  def resolve_scope_for_anonymous(relation)
    relation.none
  end
end

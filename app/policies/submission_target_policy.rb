# frozen_string_literal: true

# @see SubmissionTarget
class SubmissionTargetPolicy < ApplicationPolicy
  pre_check :deny_anonymous!, only: %i[create? update? destroy? deposit? request_deposit_access? review?]

  delegate :open?, to: :record

  def read? = allowed_to?(:show?, record.entity)

  def show? = allowed_to?(:show?, record.entity)

  # Submission targets are not directly created.
  def create? = false

  def update? = allowed_to?(:update?, record.entity)

  # Submission targets are not directly destroyed.
  def destroy? = false

  def deposit? = open? && allowed_to?(:deposit?, record.entity)

  def manage_reviewers? = update?

  def publish? = update?

  def request_deposit_access? = open? && !deposit? && no_deposit_request_exists?

  def reset_all_agreements? = update?

  def review? = allowed_to?(:review?, record.entity)

  private

  def no_deposit_request_exists? = !record.depositor_requests.exists?(user:)

  def resolve_scope_for_authenticated(relation)
    relation.visible_to(user)
  end

  def resolve_scope_for_anonymous(relation)
    relation.visible_to(nil)
  end
end

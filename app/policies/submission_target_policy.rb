# frozen_string_literal: true

# @see SubmissionTarget
class SubmissionTargetPolicy < ApplicationPolicy
  always_readable!

  pre_check :deny_anonymous!, only: %i[create? update? destroy? deposit? request_deposit_access? review?]

  delegate :open?, to: :record

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

  relation_scope do |relation|
    resolve_default_scope_for(relation)
  end

  private

  def no_deposit_request_exists? = !record.depositor_requests.exists?(user:)
end

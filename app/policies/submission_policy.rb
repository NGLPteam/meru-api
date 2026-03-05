# frozen_string_literal: true

# @see Submission
class SubmissionPolicy < ApplicationPolicy
  pre_check :deny_anonymous!

  pre_check :allow_any_admin!, except: :destroy?

  def review? = allowed_to?(:review?, record.submission_target)

  def alter_schema_version? = manage_target? && !published?

  def comment? = deposit? || review?

  def request_review? = deposit? || review?

  def migrate? = manage_target? && !published?

  def create? = deposit?

  def update? = deposit?

  # Submissions cannot be destroyed, only rejected.
  def destroy? = false

  # @!group

  private

  # @return [Submissions::Status]
  def current_status
    @current_status ||= Submissions::Status.new(record)
  end

  def deposit? = allowed_to?(:deposit?, record.submission_target)

  def manage_target? = allowed_to?(:update?, record.submission_target)

  def published? = record.state == "published"

  # @param [ActiveRecord::Relation<Submission>] relation
  def resolve_scope_for_authenticated(relation)
    relation.visible_to(user)
  end
end

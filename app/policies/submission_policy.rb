# frozen_string_literal: true

# @see Submission
class SubmissionPolicy < ApplicationPolicy
  pre_check :deny_anonymous!

  pre_check :allow_any_admin!, except: :destroy?

  def read? = manage_target? || deposit? || review? || record_owned_by_current_user?

  def show? = read?

  def index? = read?

  def alter_schema_version? = manage_target? && !published?

  def comment? = deposit? || review? || record_owned_by_current_user?

  def migrate? = manage_target? && !published?

  # @see SubmissionTargetPolicy#publish?
  def publish? = allowed_to?(:publish?, record.submission_target)

  def request_review? = deposit? || review?

  def review? = allowed_to?(:review?, record.submission_target)

  def create? = deposit?

  def update? = record_owned_by_current_user?

  # Submissions cannot be destroyed, only rejected.
  def destroy? = false

  private

  def deposit? = allowed_to?(:deposit?, record.submission_target)

  def manage_target? = allowed_to?(:update?, record.submission_target)

  def published? = record.published?

  # @param [ActiveRecord::Relation<Submission>] relation
  def resolve_scope_for_authenticated(relation)
    relation.visible_to(user)
  end
end

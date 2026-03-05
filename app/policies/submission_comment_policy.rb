# frozen_string_literal: true

# @see SubmissionComment
class SubmissionCommentPolicy < ApplicationPolicy
  pre_check :deny_anonymous!

  pre_check :allow_any_admin!

  def deposit? = allowed_to?(:deposit?, record.submission)

  def review? = allowed_to?(:review?, record.submission)

  def create? = deposit? || review?

  def update? = record_owned_by_current_user?

  def destroy? = record_owned_by_current_user?

  # @param [ActiveRecord::Relation<SubmissionComment>] relation
  def resolve_scope_for_authenticated(relation)
    relation.visible_to(user)
  end
end

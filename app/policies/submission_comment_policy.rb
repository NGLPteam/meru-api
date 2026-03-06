# frozen_string_literal: true

# @see SubmissionComment
class SubmissionCommentPolicy < ApplicationPolicy
  pre_check :deny_anonymous!

  pre_check :allow_any_admin!

  def read? = allowed_to?(:read?, record.submission)

  def show? = read?

  def index? = read?

  def create? = allowed_to?(:comment?, record.submission)

  def update? = record_owned_by_current_user?

  def destroy? = record_owned_by_current_user?

  # @param [ActiveRecord::Relation<SubmissionComment>] relation
  def resolve_scope_for_authenticated(relation)
    relation.visible_to(user)
  end
end

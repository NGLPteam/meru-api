# frozen_string_literal: true

# @see SubmissionBatchPublication
class SubmissionBatchPublicationPolicy < ApplicationPolicy
  pre_check :deny_anonymous!

  pre_check :allow_any_admin!, only: %i[read? show? index?]

  def read? = deposit? || review?

  def show? = read?

  def create? = false

  def update? = false

  def destroy? = false

  private

  def deposit? = allowed_to?(:deposit?, record.submission_target)

  def review? = allowed_to?(:review?, record.submission_target)

  # @param [ActiveRecord::Relation<SubmissionPublication>] relation
  def resolve_scope_for_authenticated(relation)
    relation.visible_to(user)
  end
end

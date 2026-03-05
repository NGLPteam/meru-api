# frozen_string_literal: true

# @see SubmissionReview
class SubmissionReviewPolicy < ApplicationPolicy
  pre_check :deny_anonymous!

  pre_check :allow_any_admin!, only: %i[read? index? show?]

  def deposit? = allowed_to?(:deposit?, record.submission)

  def review? = allowed_to?(:review?, record.submission)

  def read? = deposit? || review?

  alias_rule :index?, :show?, to: :read?

  def create? = false

  def update? = record_owned_by_current_user?

  def destroy? = record_owned_by_current_user?

  # @param [ActiveRecord::Relation<SubmissionReview>] relation
  def resolve_scope_for_authenticated(relation)
    relation.visible_to(user)
  end
end

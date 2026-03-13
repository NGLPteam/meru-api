# frozen_string_literal: true

# @see SubmissionPublication
class SubmissionPublicationPolicy < ApplicationPolicy
  pre_check :deny_anonymous!

  pre_check :allow_any_admin!, only: %i[read? show? index?]

  def read? = allowed_to?(:read?, record.submission)

  def show? = read?

  def create? = false

  def update? = false

  def destroy? = false

  private

  # @param [ActiveRecord::Relation<SubmissionPublication>] relation
  def resolve_scope_for_authenticated(relation)
    relation.visible_to(user)
  end
end

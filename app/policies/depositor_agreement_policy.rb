# frozen_string_literal: true

# @see DepositorAgreement
class DepositorAgreementPolicy < ApplicationPolicy
  pre_check :deny_anonymous!

  pre_check :allow_any_admin!, only: %i[read? show? index? reset?]

  def create? = false

  def update? = false

  def destroy? = false

  def read? = deposit? || review?

  def show? = read?

  def accept? = record.pending? && record_owned_by_current_user? && deposit?

  # Only admins can do this for now.
  def reset? = false

  private

  def deposit? = allowed_to?(:deposit?, record.submission_target)

  def review? = allowed_to?(:review?, record.submission_target)

  # @param [ActiveRecord::Relation<DepositorAgreement>] relation
  def resolve_scope_for_authenticated(relation)
    relation.visible_to(user)
  end
end

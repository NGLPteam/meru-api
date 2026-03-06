# frozen_string_literal: true

# @see Submissions::Status
class SubmissionStatusPolicy < ApplicationPolicy
  pre_check :deny_anonymous!

  pre_check :allow_managers!, only: %i[update? transition?]

  delegate :mutable_state?, :locked_state?, to: :record, prefix: :in

  def deposit? = allowed_to?(:deposit?, record.submission_target)

  def manage_target? = allowed_to?(:update?, record.target_entity)

  def update? = in_mutable_state?

  def transition? = deposit?

  private

  # @return [void]
  def allow_managers!
    allow! if in_locked_state? && manage_target?
    deny! if in_locked_state?
  end
end

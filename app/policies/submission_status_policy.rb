# frozen_string_literal: true

# @see Submissions::Status
class SubmissionStatusPolicy < ApplicationPolicy
  delegate :mutable_state?, :locked_state?, to: :record, prefix: :in

  def deposit? = allowed_to?(:deposit?, record.submission)

  def manage_target? = allowed_to?(:update?, record.target_entity)

  def update?
    return manage_target? if in_locked_state?

    in_mutable_state?
  end

  def transition?
    return manage_target? if in_locked_state?

    return true
  end
end

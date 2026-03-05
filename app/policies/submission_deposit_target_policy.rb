# frozen_string_literal: true

# @see SubmissionDepositTarget
class SubmissionDepositTargetPolicy < ApplicationPolicy
  always_readable!

  def create? = false

  def update? = false

  def destroy? = false

  def deposit? = allowed_to?(:deposit?, record.submission_target)
end

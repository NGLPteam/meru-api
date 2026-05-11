# frozen_string_literal: true

# @see SubmissionTargetReviewer
class SubmissionTargetReviewerPolicy < ApplicationPolicy
  authenticated_readable!

  def create? = allowed_to?(:manage_reviewers?, record.submission_target)

  def update? = false

  def destroy? = allowed_to?(:manage_reviewers?, record.submission_target)
end

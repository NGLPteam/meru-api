# frozen_string_literal: true

# A connection between a {SubmissionTarget} and a {User} with the role of `reviewer`,
# acting as an assignment for that user to review the submission target.
#
# Being assigned as a reviewer at the submission target level will
# grant a user a contextual `reviewer` role for any {Submission} on or under the target.
class SubmissionTargetReviewer < ApplicationRecord
  include HasEphemeralSystemSlug
  include TimestampScopes

  belongs_to :submission_target, inverse_of: :submission_target_reviewers, counter_cache: :reviewers_count
  belongs_to :user, inverse_of: :submission_target_reviewers

  scope :in_default_order, -> { joins(:user) }

  after_create_commit :assign_reviewer_role!

  before_destroy :unassign_reviewer_role!

  validates :user_id, uniqueness: { scope: :submission_target_id }

  delegate :entity, to: :submission_target

  # Assigns the user role.
  #
  # @return [Dry::Monads::Success(void)]
  monadic_operation! def assign_reviewer_role
    call_operation("access.grant", Role.fetch(:reviewer), on: entity, to: user)
  end

  # Revokes the user reviewer role.
  #
  # @return [Dry::Monads::Success(void)]
  monadic_operation! def unassign_reviewer_role
    call_operation("access.revoke", Role.fetch(:reviewer), on: entity, to: user)
  end
end

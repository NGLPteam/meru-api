# frozen_string_literal: true

# Information about a specific reviewer's review of a {Submission}.
class SubmissionReview < ApplicationRecord
  include HasEphemeralSystemSlug
  include TimestampScopes
  include UsesStatesman

  has_state_machine!

  belongs_to :submission, inverse_of: :submission_reviewers
  belongs_to :user, inverse_of: :submission_reviewers

  scope :in_default_order, -> { order(requested_at: :desc) }

  validates :user_id, uniqueness: { scope: :submission_id }

  class << self
    # @param [User, AnonymousUser] user
    # @return [ActiveRecord::Relation<SubmissionReview>]
    def visible_to(user)
      return none if user.blank? || user.anonymous?

      return all if user.has_global_admin_access?

      where(submission: Submission.visible_to(user))
    end
  end
end

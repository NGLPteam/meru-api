# frozen_string_literal: true

# A comment on a `Submission`.
class SubmissionComment < ApplicationRecord
  include HasEphemeralSystemSlug
  include TimestampScopes

  pg_enum! :role, as: :submission_comment_role, prefix: :from, allow_blank: false

  belongs_to :submission, inverse_of: :submission_comments
  belongs_to :user, inverse_of: :submission_comments

  has_one :submission_target, through: :submission

  has_one :submitter_user, through: :submission, source: :user

  positioned on: :submission

  # Newest comments to the top.
  scope :in_default_order, -> { order(position: :desc) }

  before_validation :derive_role!

  strip_attributes only: %i[content]

  validates :content, presence: true

  private

  # @return [void]
  def derive_role!
    self.role = submitter_user == user ? "submitter" : "reviewer"
  end

  class << self
    # @param [User, AnonymousUser] user
    # @return [ActiveRecord::Relation<SubmissionComment>]
    def visible_to(user)
      # :nocov:
      return none if user.blank? || user.anonymous?

      return all if user.has_global_admin_access?
      # :nocov:

      where(submission: Submission.reviewable_by(user))
    end
  end
end

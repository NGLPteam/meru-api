# frozen_string_literal: true

# @see SubmissionReview
class SubmissionReviewTransition < ApplicationRecord
  include Support::StatesmanHelpers::Transition
  include CommonTransition
  include HasEphemeralSystemSlug
  include TimestampScopes

  stateful_enum! :submission_review_state

  belongs_to :submission_review, inverse_of: :submission_review_transitions
  belongs_to :user, inverse_of: :submission_review_transitions, optional: true

  owner_association_name :submission_review

  transitions_association_name :submission_review_transitions
end

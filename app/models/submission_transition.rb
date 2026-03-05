# frozen_string_literal: true

# @see Submission
class SubmissionTransition < ApplicationRecord
  include Support::StatesmanHelpers::Transition
  include CommonTransition
  include HasEphemeralSystemSlug
  include TimestampScopes

  stateful_enum! :submission_state

  belongs_to :submission, inverse_of: :submission_transitions
  belongs_to :user, inverse_of: :submission_transitions, optional: true

  owner_association_name :submission

  transitions_association_name :submission_transitions
end

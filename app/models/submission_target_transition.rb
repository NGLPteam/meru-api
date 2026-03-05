# frozen_string_literal: true

# @see SubmissionTarget
class SubmissionTargetTransition < ApplicationRecord
  include Support::StatesmanHelpers::Transition
  include CommonTransition
  include HasEphemeralSystemSlug
  include TimestampScopes

  stateful_enum! :submission_target_state

  belongs_to :submission_target, inverse_of: :submission_target_transitions
  belongs_to :user, inverse_of: :submission_target_transitions, optional: true

  owner_association_name :submission_target

  transitions_association_name :submission_target_transitions
end

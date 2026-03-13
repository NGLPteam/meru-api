# frozen_string_literal: true

module SubmissionPublications
  # @see SubmissionPublication
  # @see SubmissionPublicationTransition
  # @see Types::SubmissionPublicationStateType
  class StateMachine
    include Statesman::Machine

    state :pending, initial: true
    state :batched
    state :success
    state :failure

    transition from: :pending, to: :batched
    transition from: :pending, to: :failure
    transition from: :pending, to: :success

    transition from: :batched, to: %i[success failure]

    transition from: :failure, to: :pending

    after_transition do |submission_publication, transition|
      submission_publication.update_column(:state, transition.to_state)
    end
  end
end

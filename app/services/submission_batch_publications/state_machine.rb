# frozen_string_literal: true

module SubmissionBatchPublications
  # @see SubmissionBatchPublication
  # @see SubmissionBatchPublicationTransition
  # @see Types::SubmissionBatchPublicationStateType
  class StateMachine
    include Statesman::Machine

    state :pending, initial: true
    state :batched
    state :finished

    transition from: :pending, to: :batched
    transition from: :pending, to: :finished

    transition from: :batched, to: :finished

    after_transition do |submission_batch_publication, transition|
      submission_batch_publication.update_column(:state, transition.to_state)
    end
  end
end

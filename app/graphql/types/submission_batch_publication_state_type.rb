# frozen_string_literal: true

module Types
  # @see SubmissionBatchPublication
  # @see SubmissionBatchPublicationTransition
  # @see SubmissionBatchPublications::StateMachine
  class SubmissionBatchPublicationStateType < Types::BaseEnum
    description <<~TEXT
    The state of a batch of submission publications.
    TEXT

    value "PENDING", value: "pending" do
      description <<~TEXT
      The batch of submissions is pending publication.
      TEXT
    end

    value "BATCHED", value: "batched" do
      description <<~TEXT
      The batch of submissions has been batched for publication and will be processed in the background.
      TEXT
    end

    value "FINISHED", value: "finished" do
      description <<~TEXT
      The batch of submissions has finished.
      TEXT
    end
  end
end

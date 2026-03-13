# frozen_string_literal: true

module Types
  # @see SubmissionPublication
  # @see SubmissionPublicationTransition
  # @see SubmissionPublications::StateMachine
  class SubmissionPublicationStateType < Types::BaseEnum
    description <<~TEXT
    The state of a submission's publication.
    TEXT

    value "PENDING", value: "pending" do
      description <<~TEXT
      The submission is pending publication.
      TEXT
    end

    value "BATCHED", value: "batched" do
      description <<~TEXT
      The submission has been batched for publication and will be processed in the background.
      TEXT
    end

    value "SUCCESS", value: "success" do
      description <<~TEXT
      The submission has been successfully published.
      TEXT
    end

    value "FAILURE", value: "failure" do
      description <<~TEXT
      The submission failed to publish.
      TEXT
    end
  end
end

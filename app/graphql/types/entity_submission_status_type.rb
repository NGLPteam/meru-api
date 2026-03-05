# frozen_string_literal: true

module Types
  class EntitySubmissionStatusType < Types::BaseEnum
    description <<~TEXT
    An enum describing the submission state of an actual entity record.

    It can have an effect on the visibility and available of records from the frontend.
    TEXT

    value "UNSUBMITTED", value: "unsubmitted" do
      description <<~TEXT
      This entity has no submission associated with it.

      Its submission state has no effect on the visibility nor availability of the entity from the frontend.
      TEXT
    end

    value "SUBMISSION_DRAFT", value: "submission_draft" do
      description <<~TEXT
      This entity has a submission in draft state.

      It will not be visible nor available from the frontend until it is published.
      TEXT
    end

    value "SUBMISSION_PUBLISHED", value: "submission_published" do
      description <<~TEXT
      This entity has a submission in published state.

      It will be visible and available from the frontend.
      TEXT
    end
  end
end

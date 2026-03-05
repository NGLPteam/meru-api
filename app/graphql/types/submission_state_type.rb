# frozen_string_literal: true

module Types
  # @see Submissions::StateMachine
  class SubmissionStateType < Types::BaseEnum
    description <<~TEXT
    The status of a `Submission`.
    TEXT

    value "DRAFT", value: "draft" do
      description <<~TEXT
      The initial draft state of a submission.
      TEXT
    end

    value "SUBMITTED", value: "submitted" do
      description <<~TEXT
      The depositor has submitted the submission for review.
      TEXT
    end

    value "UNDER_REVIEW", value: "under_review" do
      description <<~TEXT
      The submission is currently under review.
      TEXT
    end

    value "REVISION_REQUESTED", value: "revision_requested" do
      description <<~TEXT
      The review staff has requested revisions to the submission
      and the depositor is expected to make changes and resubmit.
      TEXT
    end

    value "APPROVED", value: "approved" do
      description <<~TEXT
      The submission has been approved by the review staff and is awaiting publication.
      TEXT
    end

    value "REJECTED", value: "rejected" do
      description <<~TEXT
      The submission has been rejected by the review staff and will not be published,
      and is not subject to any further reviews or revisions.
      TEXT
    end

    value "PUBLISHED", value: "published" do
      description <<~TEXT
      The submission has been published and is publicly visible.
      TEXT
    end
  end
end

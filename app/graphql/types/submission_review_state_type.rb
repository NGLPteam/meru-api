# frozen_string_literal: true

module Types
  class SubmissionReviewStateType < Types::BaseEnum
    description <<~TEXT
    The status of a specific reviewer's review on a submission.
    TEXT

    value "PENDING", value: "pending" do
      description <<~TEXT
      The review is pending / requested and has not yet been acted upon.
      TEXT
    end

    value "APPROVED", value: "approved" do
      description <<~TEXT
      The reviewer has approved the submission.
      TEXT
    end

    value "REJECTED", value: "rejected" do
      description <<~TEXT
      The reviewer has rejected the submission.
      TEXT
    end
  end
end

# frozen_string_literal: true

module Types
  class DepositorAgreementStateType < Types::BaseEnum
    description <<~TEXT
    The state of a user's acceptance of a given `SubmissionTarget`'s agreement requirements.
    TEXT

    value "PENDING", value: "pending" do
      description <<~TEXT
      The user has not yet accepted the agreement for the submission target.
      TEXT
    end

    value "ACCEPTED", value: "accepted" do
      description <<~TEXT
      The user has accepted the agreement for the submission target.
      TEXT
    end
  end
end

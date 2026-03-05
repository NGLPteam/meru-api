# frozen_string_literal: true

module Types
  # A role on a {SubmissionComment}.
  class SubmissionCommentRoleType < Types::BaseEnum
    description <<~TEXT
    The role of a commenter on a `SubmissionComment`.
    TEXT

    value "SUBMITTER", value: "submitter" do
      description <<~TEXT
      This comment is from the submitter.
      TEXT
    end

    value "REVIEWER", value: "reviewer" do
      description <<~TEXT
      This comment is from a reviewer, manager, admin, or other user with privileges.
      TEXT
    end
  end
end

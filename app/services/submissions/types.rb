# frozen_string_literal: true

module Submissions
  # Types for working with {Submission} operations and services.
  module Types
    extend ::Support::Typespace

    Submission = ModelInstance("Submission")

    SubmissionPublication = ModelInstance("SubmissionPublication")

    SubmissionTarget = ModelInstance("SubmissionTarget")

    State = ApplicationRecord.dry_pg_enum("submission_state", default: "draft")

    User = ModelInstance("User")
  end
end

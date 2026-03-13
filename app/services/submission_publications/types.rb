# frozen_string_literal: true

module SubmissionPublications
  # Types for working with {SubmissionPublication} operations and services.
  module Types
    extend ::Support::Typespace

    Submission = ModelInstance("Submission")

    SubmissionBatchPublication = ModelInstance("SubmissionBatchPublication")

    SubmissionPublication = ModelInstance("SubmissionPublication")

    SubmissionTarget = ModelInstance("SubmissionTarget")

    State = ApplicationRecord.dry_pg_enum("submission_publication_state", default: "pending")

    User = ModelInstance("User")
  end
end

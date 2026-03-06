# frozen_string_literal: true

module Submissions
  # Types for working with {Submission} operations and services.
  module Types
    include Dry.Types

    extend Support::EnhancedTypes

    Submission = ModelInstance("Submission")

    SubmissionTarget = ModelInstance("SubmissionTarget")

    State = ApplicationRecord.dry_pg_enum("submission_state", default: "draft")
  end
end

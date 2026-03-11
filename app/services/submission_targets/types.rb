# frozen_string_literal: true

module SubmissionTargets
  # Types for working with {SubmissionTarget} operations and services.
  module Types
    extend ::Support::Typespace

    DepositMode = ApplicationRecord.dry_pg_enum(:submission_deposit_mode, default: "direct").fallback("direct")

    Entity = Instance(::HierarchicalEntity)

    DepositTarget = Entity

    DepositTargets = Array.of(DepositTarget)

    SchemaVersion = ModelInstance("SchemaVersion")

    SchemaVersions = Array.of(SchemaVersion)

    Submission = ModelInstance("Submission")

    SubmissionTarget = ModelInstance("SubmissionTarget")

    Configurable = Entity | SubmissionTarget
  end
end

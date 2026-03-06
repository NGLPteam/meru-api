# frozen_string_literal: true

# A concern for models that can be submitted to a {SubmissionTarget}.
module Submittable
  extend ActiveSupport::Concern
  extend DefinesMonadicOperation

  included do
    pg_enum! :submission_status, as: :entity_submission_status, allow_blank: false, default: "unsubmitted"

    has_one :submission_target, as: :entity, dependent: :destroy, inverse_of: :entity

    has_many :submission_deposit_targets, as: :entity, dependent: :destroy, inverse_of: :entity

    has_many :child_submissions, as: :parent_entity, dependent: :nullify, inverse_of: :parent_entity,
      class_name: "Submission"

    has_one :submission, as: :entity, dependent: :nullify, inverse_of: :entity

    has_one :submitter, through: :submission, source: :user
  end

  # @see SubmissionTargets::Configure
  # @see SubmissionTargets::Configurator
  # @return [Dry::Monads::Success(SubmissionTarget)]
  monadic_operation! def configure_submission_target(**options)
    call_operation("submission_targets.configure", self, **options)
  end

  # @see SubmissionTargets::Fetch
  # @see SubmissionTargets::Fetcher
  # @return [Dry::Monads::Success(SubmissionTarget)]
  monadic_operation! def fetch_submission_target
    call_operation("submission_targets.fetch", self)
  end
end

# frozen_string_literal: true

module SubmissionTargets
  # @see SubmissionTargets::BatchPublisher
  class BatchPublish < Support::SimpleServiceOperation
    service_klass SubmissionTargets::BatchPublisher
  end
end

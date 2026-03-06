# frozen_string_literal: true

module SubmissionTargets
  # @see SubmissionTargets::Fetcher
  class Fetch < Support::SimpleServiceOperation
    service_klass SubmissionTargets::Fetcher
  end
end

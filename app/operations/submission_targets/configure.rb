# frozen_string_literal: true

module SubmissionTargets
  # @see SubmissionTargets::Configurator
  class Configure < Support::SimpleServiceOperation
    service_klass SubmissionTargets::Configurator
  end
end

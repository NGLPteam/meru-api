# frozen_string_literal: true

module Processing
  # @see Processing::Reprocessor
  class Reprocess < Support::SimpleServiceOperation
    service_klass Processing::Reprocessor
  end
end

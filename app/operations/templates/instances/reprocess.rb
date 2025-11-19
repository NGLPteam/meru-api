# frozen_string_literal: true

module Templates
  module Instances
    # @see Templates::Instances::Reprocessor
    class Reprocess < Support::SimpleServiceOperation
      service_klass Templates::Instances::Reprocessor
    end
  end
end

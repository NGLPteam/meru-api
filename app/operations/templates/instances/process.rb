# frozen_string_literal: true

module Templates
  module Instances
    # @see Templates::Instances::Processor
    class Process < Support::SimpleServiceOperation
      service_klass Templates::Instances::Processor
    end
  end
end

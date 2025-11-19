# frozen_string_literal: true

module Layouts
  module Instances
    # @see Layouts::Instances::Processor
    class Process < Support::SimpleServiceOperation
      service_klass Layouts::Instances::Processor
    end
  end
end

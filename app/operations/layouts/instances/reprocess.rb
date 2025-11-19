# frozen_string_literal: true

module Layouts
  module Instances
    # @see Layouts::Instances::Reprocessor
    class Reprocess < Support::SimpleServiceOperation
      service_klass Layouts::Instances::Reprocessor
    end
  end
end

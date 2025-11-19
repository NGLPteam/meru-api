# frozen_string_literal: true

module Layouts
  module Instances
    # @see Layouts::Instances::PostProcessor
    class PostProcess < Support::SimpleServiceOperation
      service_klass Layouts::Instances::PostProcessor
    end
  end
end

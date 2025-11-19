# frozen_string_literal: true

module Templates
  module Instances
    # @see Templates::Instances::PostProcessor
    class PostProcess < Support::SimpleServiceOperation
      service_klass Templates::Instances::PostProcessor
    end
  end
end

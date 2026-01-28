# frozen_string_literal: true

module Schemas
  module Orderings
    module Stats
      # @see Schemas::Orderings::Stats::Calculator
      class Calculate < Support::SimpleServiceOperation
        service_klass Schemas::Orderings::Stats::Calculator
      end
    end
  end
end

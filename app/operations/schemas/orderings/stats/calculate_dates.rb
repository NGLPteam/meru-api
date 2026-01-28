# frozen_string_literal: true

module Schemas
  module Orderings
    module Stats
      # @see Schemas::Orderings::Stats::DatesCalculator
      class CalculateDates < Support::SimpleServiceOperation
        service_klass Schemas::Orderings::Stats::DatesCalculator
      end
    end
  end
end

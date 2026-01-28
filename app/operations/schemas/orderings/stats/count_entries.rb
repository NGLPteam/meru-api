# frozen_string_literal: true

module Schemas
  module Orderings
    module Stats
      # @see Schemas::Orderings::Stats::EntriesCounter
      class CountEntries < Support::SimpleServiceOperation
        service_klass Schemas::Orderings::Stats::EntriesCounter
      end
    end
  end
end

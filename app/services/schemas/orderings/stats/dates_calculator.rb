# frozen_string_literal: true

module Schemas
  module Orderings
    module Stats
      # @see Schemas::Orderings::Stats::CalculateDates
      class DatesCalculator < Support::HookBased::Actor
        include Dry::Initializer[undefined: false].define -> do
          param :ordering, Schemas::Types::Ordering

          option :attrs, Types::Hash, default: proc { {} }

          option :only_calculate, Types::Bool, default: proc { false }
        end

        standard_execution!

        # @return [OrderingDateRange, nil]
        attr_reader :ordering_date_range

        # @return [VariablePrecisionDate]
        attr_reader :oldest_published

        # @return [VariablePrecisionDate]
        attr_reader :latest_published

        # @return [Dry::Monads::Success(Ordering)]
        def call
          run_callbacks :execute do
            yield prepare!

            yield persist! unless only_calculate
          end

          Success ordering
        end

        wrapped_hook! def prepare
          @ordering_date_range = ordering.reload_ordering_date_range

          @oldest_published = ordering_date_range&.oldest_published || VariablePrecisionDate.none
          @latest_published = ordering_date_range&.latest_published || VariablePrecisionDate.none

          attrs.merge!(oldest_published:, latest_published:)

          super
        end

        wrapped_hook! def persist
          ordering.update_columns(@attrs)

          super
        end
      end
    end
  end
end

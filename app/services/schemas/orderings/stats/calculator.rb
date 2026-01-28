# frozen_string_literal: true

module Schemas
  module Orderings
    module Stats
      # @see Schemas::Orderings::Stats::Calculate
      class Calculator < Support::HookBased::Actor
        include Dry::Initializer[undefined: false].define -> do
          param :ordering, Schemas::Types::Ordering
        end

        standard_execution!

        # @return [Hash]
        attr_reader :attrs

        # @return [Dry::Monads::Success(Ordering)]
        def call
          run_callbacks :execute do
            yield prepare!

            yield count_entries!

            yield calculate_dates!

            yield persist!
          end

          Success ordering
        end

        wrapped_hook! def prepare
          @attrs = {}

          super
        end

        wrapped_hook! def count_entries
          yield ordering.count_entries(attrs:, only_calculate: true)

          super
        end

        wrapped_hook! def calculate_dates
          yield ordering.calculate_dates(attrs:, only_calculate: true)

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

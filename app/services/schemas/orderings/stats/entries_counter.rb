# frozen_string_literal: true

module Schemas
  module Orderings
    module Stats
      # @see Schemas::Orderings::Stats::CountEntries
      class EntriesCounter < Support::HookBased::Actor
        include Dry::Initializer[undefined: false].define -> do
          param :ordering, Schemas::Types::Ordering

          option :attrs, Types::Hash, default: proc { {} }

          option :only_calculate, Types::Bool, default: proc { false }
        end

        standard_execution!

        # @return [OrderingEntryCount, nil]
        attr_reader :ordering_entry_count

        # @return [Integer]
        attr_reader :entries_count

        # @return [Integer]
        attr_reader :visible_count

        # @return [Dry::Monads::Success(Hash)]
        def call
          run_callbacks :execute do
            yield prepare!

            yield persist! unless only_calculate
          end

          Success ordering
        end

        wrapped_hook! def prepare
          @ordering_entry_count = ordering.reload_ordering_entry_count

          @entries_count = ordering_entry_count&.entries_count || 0
          @visible_count = ordering_entry_count&.visible_count || 0

          attrs.merge!(entries_count:, visible_count:)

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

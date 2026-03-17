# frozen_string_literal: true

module Schemas
  # Dynamic, automatically-maintained orderings of entities for specific schema versions.
  module Orderings
    class << self
      # Set options for refreshing orderings as a part of model lifecycles.
      #
      # @see Schemas::Orderings::Current.refresh_with!
      # @see Schemas::Orderings::Refresh
      # @see Schemas::Orderings::RefreshStatus
      # @param ["async", "disabled", "sync"] mode
      # @yield a block where the provided refresh mode will be in effect
      # @return [void]
      def refresh_with!(mode:, &)
        Schemas::Orderings::Current.refresh_with!(mode:, &)
      end

      # Rather than refresh orderings immediately, specify that they should be
      # enqueued in the backend.
      #
      # @see .refresh_with!
      # @return [void]
      def with_asynchronous_refresh(&)
        refresh_with!(mode: "async", &)
      end

      # Disable refreshing orderings entirely for the duration of the block.
      # May be used in tests, or for manual fixes that will end up reprocessing
      # a significant number of orderings en masse after completion.
      #
      # @see .refresh_with!
      # @return [void]
      def with_disabled_refresh(&)
        refresh_with!(mode: "disabled", &)
      end
    end
  end
end

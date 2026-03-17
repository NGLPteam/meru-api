# frozen_string_literal: true

module Schemas
  module Orderings
    # @api private
    # @see Schemas::Instances::RefreshOrderings
    # @see Schemas::Instances::RefreshOrderingsJob
    # @see Schemas::Orderings.refresh_with!
    class RefreshStatus
      include Dry::Initializer[undefined: false].define -> do
        option :mode, Schemas::Orderings::Types::RefreshMode, default: proc { "sync" }
      end

      # @return [Boolean]
      attr_reader :async

      alias async? async

      # @return [Boolean]
      attr_reader :disabled

      alias disabled? disabled

      # @return [Boolean]
      attr_reader :sync

      alias sync? sync

      def initialize(...)
        super

        @async = mode == "async"
        @disabled = mode == "disabled"
        @sync = mode == "sync"
      end
    end
  end
end

# frozen_string_literal: true

module Support
  module HookBased
    # @abstract
    class Actor
      extend ActiveModel::Callbacks
      extend Dry::Core::ClassAttributes
      extend Support::DoFor

      include Support::CallsCommonOperation

      include Dry::Core::Constants

      include Dry::Monads[:result, :maybe, :try]

      # @api private
      TO_RESULT = Support::MonadHelpers::ToResult.new

      private_constant :TO_RESULT

      defines :benchmark_hooks, type: Types::Bool

      benchmark_hooks false

      # @return [Symbol]
      attr_reader :current_hook

      # @api private
      def inspect
        # :nocov:
        "#<#{self.class}>"
        # :nocov:
      end

      # @api private
      # @yieldreturn [Dry::Monads::Result]
      # @return [Dry::Monads::Result]
      def enforce_monadic
        retval = yield

        TO_RESULT.call(retval)
      end

      def benchmark_hook!
        # :nocov:
        time = AbsoluteTime.realtime do
          yield
        end

        warn "hook #{current_hook} took #{time}s"
        # :nocov:
      end

      def benchmark_hooks?
        self.class.benchmark_hooks && Rails.env.development?
      end

      class << self
        # @return [void]
        def benchmark_hooks!
          benchmark_hooks true
        end

        def standard_execution!
          do_for! :call

          define_model_callbacks :execute
        end

        def wrapped_hook!(name)
          mod = WrappedHook.new(name)

          include mod
        end
      end
    end
  end
end

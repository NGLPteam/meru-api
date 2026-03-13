# frozen_string_literal: true

module Support
  module Requests
    # A state object that wraps GraphQL requests and provides certain caching
    # and other support in the context.
    #
    # @see Support::Requests::Current
    class State
      extend ActiveModel::Callbacks

      define_model_callbacks :request

      around_request :provide_current_state!

      around_request :measure!, if: :timer?

      # @return [Support::Requests::Timer, nil]
      attr_reader :timer

      def timer? = timer.present?

      # @return [void]
      def set_up_timer!(...)
        @timer = Timer.new(...)
      end

      # @yieldreturn [void]
      # @return [void]
      def wrap
        run_callbacks :request do
          yield
        end
      end

      private

      # @return [void]
      def measure!
        timer.measure! do
          yield
        end
      end

      # @return [void]
      def provide_current_state!(&)
        Support::Requests::Current.set(state: self, &)
      end
    end
  end
end

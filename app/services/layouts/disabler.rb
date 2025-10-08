# frozen_string_literal: true

module Layouts
  class Disabler
    include Dry::Effects::Handler.Reader(:layout_invalidation_disabled)
    include Dry::Effects.Reader(:layout_invalidation_disabled, default: false)

    # @return [void]
    def disable!
      return yield if layout_invalidation_disabled

      with_layout_invalidation_disabled(true) do
        yield
      end
    end

    class << self
      def instance
        @instance ||= new
      end

      # @return [void]
      def disable!
        instance.disable! { yield }
      end
    end
  end
end

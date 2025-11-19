# frozen_string_literal: true

module Layouts
  # @see Layouts::Disabled
  class Disabler
    # @return [void]
    def disable!
      Layouts::Disabled.set(currently: true) do
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

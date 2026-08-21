# frozen_string_literal: true

module Processing
  # @abstract
  class Actor < Support::HookBased::Actor
    extend Dry::Initializer

    standard_execution!

    around_execute :disable_ordering_refresh!

    private

    # @return [void]
    def disable_ordering_refresh!
      Schemas::Orderings.with_disabled_refresh do
        yield
      end
    end

    class << self
      def inherited(subclass)
        super

        subclass.standard_execution!
      end
    end
  end
end

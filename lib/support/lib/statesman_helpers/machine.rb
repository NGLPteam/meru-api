# frozen_string_literal: true

module Support
  module StatesmanHelpers
    # An enhancement to Statesman::Machine that adds flexible transitions.
    module Machine
      extend ActiveSupport::Concern

      included do
        include Statesman::Machine
      end

      module ClassMethods
        # Define transitions that allow any state to transition into any other state
        # @return [void]
        def flexible_transitions!
          states.each do |from|
            to = states.without(from)

            transition(from:, to:)
          end
        end
      end
    end
  end
end

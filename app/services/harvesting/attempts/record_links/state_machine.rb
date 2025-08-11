# frozen_string_literal: true

module Harvesting
  module Attempts
    module RecordLinks
      # @see HarvestAttemptRecordLink
      class StateMachine
        include Statesman::Machine
        include Support::StatesmanHelpers::Machine

        state :pending, initial: true
        state :extracted
        state :upserted
        state :success
        state :cancelled

        flexible_transitions!

        after_transition to: :upserted do |harl, _transition|
          # :nocov:
          harl.transition_to :success
          # :nocov:
        end
      end
    end
  end
end

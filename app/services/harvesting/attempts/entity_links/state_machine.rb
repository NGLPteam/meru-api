# frozen_string_literal: true

module Harvesting
  module Attempts
    module EntityLinks
      # @see HarvestAttemptEntityLink
      class StateMachine
        include Statesman::Machine
        include Support::StatesmanHelpers::Machine

        state :pending, initial: true
        state :upserted
        state :assets_fetched
        state :success
        state :cancelled

        flexible_transitions!

        after_transition to: :upserted do |hael, _transition|
          hael.transition_to :success unless hael.assets?
        end

        after_transition to: :assets_fetched do |hael, _transition|
          # :nocov:
          hael.transition_to :success if hael.assets?
          # :nocov:
        end

        after_transition to: :success do |hael, _transition|
          hael.check_record_for_success!
        end
      end
    end
  end
end

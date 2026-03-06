# frozen_string_literal: true

# A helper concern to DRY up state machine wiring in models.
module UsesStatesman
  extend ActiveSupport::Concern

  module ClassMethods
    # @return [Support::StatesmanHelpers::Configuration]
    def default_state_machine
      state_machines[default_transitions_name]
    end

    # @return [Class(CommonTransition)]
    def default_transition_class
      default_state_machine.transition_class
    end

    # @return [String]
    def default_transitions_name
      @default_transitions_name ||= "#{model_name.singular}_transitions"
    end

    # Define a conventions-based state machine.
    #
    # @see Support::StatesmanHelpers::KlassRegistry#build!
    def has_state_machine!(...)
      state_machines.build!(...)
    end

    # @!attribute [r] state_machines
    # @api private
    # @return [Support::StatesmanHelpers::KlassRegistry]
    def state_machines
      @state_machines ||= Support::StatesmanHelpers::KlassRegistry.new(self)
    end
  end
end

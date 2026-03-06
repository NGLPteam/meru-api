# frozen_string_literal: true

module Support
  module StatesmanHelpers
    class Configuration
      include Dry::Core::Memoizable
      include Dry::Initializer[undefined: false].define -> do
        param :klass, ::Support::Models::Types::ModelClass

        option :association, Types::AssociationName
        option :prefix, Types::Coercible::Symbol.optional, optional: true
        option :machine_class, Types::MachineClass
        option :initial_transition, Types::Bool, default: proc { true }
        option :transition_class, Types::TransitionClass
        option :inverse_of, Types::AssociationName, default: proc { klass.model_name.singular }
        option :machine_name, Types::AssociationName, default: proc { [prefix, "state_machine"].compact.join(?_).to_sym }
        option :predicates, Types::Predicates, default: proc { [] }
        option :include_can_transition, Types::Bool, default: proc { false }
      end

      delegate :initial_state, to: :machine_class

      alias initial_transition? initial_transition

      alias key association

      # @return [Symbol]
      memoize def build_machine_name
        :"build_#{machine_name}"
      end

      # @return [Symbol]
      memoize def rebuild_machine_name
        :"rebuild_#{machine_name}!"
      end

      # @return [Symbol]
      memoize def machine_ivar
        :"@#{machine_name}"
      end

      # @return [Symbol]
      memoize def module_name
        [association, :methods].join(?_).camelize.to_sym
      end

      # @return [{ Symbol => Symbol }]
      memoize def predicate_states
        if predicates == :ALL
          Types::Predicates[machine_class.states]
        else
          predicates.select do |state|
            state.to_s.in? machine_class.states
          end
        end.index_by do |state|
          base = [prefix, state].compact.join(?_)

          :"#{base}?"
        end
      end
    end
  end
end

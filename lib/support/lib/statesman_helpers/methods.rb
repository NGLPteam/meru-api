# frozen_string_literal: true

module Support
  module StatesmanHelpers
    # @api private
    class Methods < Module
      # @api private
      DELEGATED_STATE_MACHINE_METHODS = [
        :can_transition_to?,
        :current_state, :history,
        :last_transition, :last_transition_to,
        :transition_to!, :transition_to,
        :in_state?,
      ].freeze

      delegate :machine_name, :prefix, to: :@config

      # @return [StatesmanHelpers::Configuration]
      attr_reader :config

      # @param [StatesmanHelpers::Configuration] config
      def initialize(config:)
        @config = config

        class_eval <<~RUBY, __FILE__, __LINE__ + 1
        def #{config.machine_name}
          #{config.machine_ivar} ||= #{config.build_machine_name}
        end

        def #{config.build_machine_name}
          ::#{config.machine_class}.new(
            self,
            transition_class: ::#{config.transition_class},
            initial_transition: #{config.initial_transition?}
          )
        end

        def #{config.rebuild_machine_name}
          #{config.machine_ivar} = #{config.build_machine_name}
        end

        #{compile_predicates}
        RUBY
      end

      # @param [Class] klass
      # @return [void]
      def included(klass)
        configure_association! klass

        delegate_state_machine_for! klass

        attach_queries_mod! klass

        klass.after_save config.rebuild_machine_name
      end

      private

      # @return [String]
      def compile_predicates
        config.predicate_states.map do |(name, state)|
          <<~RUBY
          def #{name}(force_reload: false)
            #{config.machine_name}.current_state(force_reload:) if force_reload

            #{config.machine_name}.in_state?(#{state.inspect})
          end
          RUBY
        end.join("\n\n")
      end

      # @param [Class] klass
      # @return [void]
      def configure_association!(klass)
        options = {
          autosave: false,
          inverse_of: config.inverse_of,
          dependent: :delete_all
        }

        klass.has_many config.association, **options
      end

      # @param [Class] klass
      # @return [void]
      def delegate_state_machine_for!(klass)
        machine_delegation_options = {
          prefix:,
          to: machine_name,
        }.compact

        klass.delegate(*DELEGATED_STATE_MACHINE_METHODS, **machine_delegation_options)

        can_transition_to = [prefix, :can_transition_to?].compact_blank.join(?_).to_sym

        has_available_transition = [:has_available, prefix, :transition?].compact_blank.join(?_).to_sym

        klass.alias_method has_available_transition, can_transition_to
      end

      # @param [Class] klass
      # @return [void]
      def attach_queries_mod!(klass)
        return unless config.prefix.nil?

        klass.include Statesman::Adapters::ActiveRecordQueries[
          transition_class: config.transition_class,
          initial_state: config.initial_state
        ]
      end
    end
  end
end

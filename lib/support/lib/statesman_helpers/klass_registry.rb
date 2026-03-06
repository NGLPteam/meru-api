# frozen_string_literal: true

module Support
  module StatesmanHelpers
    class KlassRegistry
      include Dry::Container::Mixin
      include Dry::Core::Memoizable
      include Dry::Initializer[undefined: false].define -> do
        param :klass, StatesmanHelpers::Types.Inherits(ActiveRecord::Base)
      end

      SUBCLASS_TYPES = {
        machine_class: Types::MachineClass,
        transition_class: Types::TransitionClass,
      }.freeze

      delegate :model_name, to: :klass

      # @return [void]
      def build!(
        prefix: nil,
        association: nil,
        machine_class: nil,
        transition_class: nil,
        **options
      )
        association ||= association_for(prefix:)
        machine_class ||= machine_class_for(prefix:)
        transition_class ||= transition_class_for(prefix:)

        options.merge!(prefix:, association:, machine_class:, transition_class:)

        config = Configuration.new(klass, **options)

        register(config.key, config)

        mod = Methods.new(config:)

        klass.const_set config.module_name, mod

        klass.include mod
      end

      memoize def model_namespace
        model_name.plural
      end

      # @!group Derivation Helpers

      def association_for(prefix: nil)
        [model_name.singular, prefix, "transition"].compact.join(?_).tableize.to_sym
      end

      # @param [String] prefix
      # @return [Class]
      def machine_class_for(prefix: nil)
        try_subclass! :machine_class, prefix: do |c|
          basename = [prefix, "state_machine"].compact.join(?_)

          c << "#{model_namespace}/#{basename}".classify
        end
      end

      # @param [String] prefix
      # @return [Class]
      def transition_class_for(prefix: nil)
        try_subclass! :transition_class, prefix: do |c|
          c << [model_name.singular, prefix, "transition"].compact.join(?_).classify
        end
      end

      # @!endgroup Derivation Helpers

      private

      # @yieldparam [<String>] candidates
      # @yieldreturn [void]
      # @return [Class]
      def try_subclass!(key, prefix: nil)
        type = SUBCLASS_TYPES.fetch key

        candidates = []

        yield candidates

        found = candidates.reduce(nil) do |kls, candidate|
          kls || candidate.safe_constantize
        end

        # :nocov:
        raise StatesmanHelpers::MissingClassError, "Could not derive #{key.inspect} with prefix: #{prefix.inspect}" unless type.valid?(found)
        # :nocov:

        return found
      end
    end
  end
end

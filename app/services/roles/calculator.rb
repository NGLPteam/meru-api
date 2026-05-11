# frozen_string_literal: true

module Roles
  # @see Roles::CalculateSystem
  class Calculator < Support::HookBased::Actor
    extend Dry::Core::ClassAttributes

    defines :mappings, type: Roles::Types::RoleMappings

    mappings Dry::Core::Constants::EMPTY_HASH

    standard_execution!

    # @return [<{ Symbol => Hash }>]
    attr_reader :definitions

    # @return [{ Symbol => Hash }]
    attr_reader :roles

    # @return [Dry::Monads::Success<{ Symbol => Hash }>]
    def call
      run_callbacks :execute do
        yield prepare!

        yield define!

        yield finalize!
      end

      Success definitions
    end

    wrapped_hook! def prepare
      @definitions = []

      @roles = {}

      super
    end

    wrapped_hook! def define
      mappings.each_value do |mapping|
        define_from_mapping!(**mapping)
      end

      super
    end

    wrapped_hook! def finalize
      @definitions = roles.values.freeze

      super
    end

    private

    # @param [Symbol] identifier
    # @param [Proc] dsl A block to be passed to {Roles::Definer#call}.
    # @param [Hash] options
    # @option options [String] :name
    # @return [void]
    def define_from_mapping!(identifier:, dsl:, options: {})
      role!(identifier, **options, &dsl)
    end

    def mappings = self.class.mappings

    # @param [Symbol] identifier
    # @param [Hash] options
    # @option options [String] :name
    # @yield [dsl] DSL for defining the role's permissions
    # @yieldparam [Roles::Definer] dsl
    # @yieldreturn [void]
    # @return [void]
    def role!(identifier, **options, &)
      definer = Roles::Definer.new(identifier, **options)

      roles[definer.identifier] = definer.call(&)

      return
    end

    class << self
      # @param [Symbol] identifier
      # @param [Hash] options
      # @option options [String] :name
      # @yield [dsl] DSL for defining the role's permissions
      # @yieldparam [Roles::Definer] dsl
      # @yieldreturn [void]
      # @return [void]
      def role!(identifier, **options, &dsl)
        mapping = { identifier:, options:, dsl:, }

        new_mappings = mappings.merge(identifier => mapping).freeze

        mappings new_mappings
      end
    end
  end
end

# frozen_string_literal: true

module NamedVariableDates
  # A shared interface for building methods related to accessing a {NamedVariableDate}.
  # @abstract
  class MethodBuilder < Module
    include Dry::Initializer.define -> do
      param :name, NamedVariableDates::Types::GlobalName
    end

    def initialize(...)
      super

      compile_methods!
    end

    def inspect
      # simplecov:disable
      "#{self.class.name}[#{@name.inspect}]"
      # simplecov:enable
    end

    private

    # Compile the methods to be included with this module.
    #
    # @abstract
    # @return [void]
    def compile_methods!; end

    class << self
      def for(name)
        generated_module_cache.compute_if_absent name do
          new name
        end
      end

      # @api private
      # @return [Concurrent::Map]
      def generated_module_cache
        @generated_module_cache ||= Concurrent::Map.new
      end
    end
  end
end

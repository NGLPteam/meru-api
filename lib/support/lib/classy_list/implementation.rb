# frozen_string_literal: true

module Support
  module ClassyList
    # @api private
    # @abstract A base implementation metamodule for classy lists.
    class Implementation < Module
      extend Dry::Core::ClassAttributes

      include Dry::Initializer[undefined: false].define -> do
        param :config, Support::ClassyList::Configuration::Type
      end

      defines :module_infix, type: Types::Symbol

      module_infix :unknown

      delegate :list_name, :config_name, :single_dsl_method, :plural_dsl_method, :realize_method, :ivar, to: :config

      # @return [Symbol]
      attr_reader :module_name

      def initialize(...)
        super

        @module_name = [list_name, module_infix, "methods"].join(?_).camelize(:upper)
      end

      def extended(base)
        super

        attach_to!(base)
      end

      def included(base)
        super

        attach_to!(base)
      end

      private

      def attach_to!(base)
        # base.const_set module_name, self
      end

      # @return [Symbol]
      def module_infix = self.class.module_infix
    end
  end
end

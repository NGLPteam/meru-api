# frozen_string_literal: true

module Support
  module HookBased
    # @abstract
    class AbstractProvider < Module
      extend Dry::Core::ClassAttributes
      extend Dry::Initializer

      param :attribute, Types::Attribute

      option :provider_name, Types::Symbol, default: proc { :"provide_#{attribute}!" }
      option :skip_attr_reader, Types::Bool, default: proc { false }

      def initialize(...)
        super

        define_provider!
      end

      def inspect
        # simplecov:disable
        "#{self.class}[#{attribute.inspect}]"
        # simplecov:enable
      end

      def included(base)
        super

        base.attr_reader attribute unless skip_attr_reader

        base.include build_effect!
      end

      private

      # @abstract
      # @return [void]
      def build_effect!
        # simplecov:disable
        raise NotImplementedError, "must implement #{self.class}##{__method__}"
        # simplecov:enable
      end

      # @abstract
      # @return [void]
      def define_provider!
        # simplecov:disable
        raise NotImplementedError, "must implement #{self.class}##{__method__}"
        # simplecov:enable
      end
    end
  end
end

# frozen_string_literal: true

module Support
  module ModelTypes
    module Common
      extend ActiveSupport::Concern

      included do
        extend Dry::Core::ClassAttributes

        defines :type, type: Support::Types::Symbol.constrained(filled: true)

        type name.demodulize.underscore.to_sym
      end

      # @return [Symbol]
      def type
        # :nocov:
        self.class.type
        # :nocov:
      end
    end
  end
end

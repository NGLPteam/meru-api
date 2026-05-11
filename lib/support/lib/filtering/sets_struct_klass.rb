# frozen_string_literal: true

module Support
  module Filtering
    # A concern for GraphQL object types that set a filtering match struct class
    module SetsStructKlass
      extend ActiveSupport::Concern

      included do
        extend Dry::Core::ClassAttributes

        defines :struct_klass_name, type: ::Support::Filtering::Types::String

        struct_klass_name "::Support::Filtering::Inputs::ComparatorMatch"
      end

      private

      # @!attribute [r] struct_klass
      # @return [Class(Support::Filtering::Inputs::ComparatorMatch)]
      def struct_klass = self.class.struct_klass

      # Class methods for the including class.
      # @api private
      module ClassMethods
        # @!attribute [r] struct_klass
        # @!scope class
        # @return [Class(Support::Filtering::Inputs::ComparatorMatch)]
        def struct_klass
          @struct_klass ||= struct_klass_name.constantize
        end
      end
    end
  end
end

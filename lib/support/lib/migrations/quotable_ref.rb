# frozen_string_literal: true

module Support
  module Migrations
    # @abstract
    class QuotableRef
      extend Dry::Initializer

      include Dry::Core::Memoizable

      include QuotationHelpers

      param :root, Support::Types::Coercible::String

      option :prefix, Support::Types::Coercible::String.optional, default: proc {}
      option :suffix, Support::Types::Coercible::String.optional, default: proc {}
      option :quote_by_default, Support::Types::Bool, default: proc { true }

      # @return [String]
      memoize def quoted
        quote unquoted
      end

      # @return [String]
      memoize def unquoted
        compile
      end

      # @return [String]
      memoize def value_quoted
        connection.quote unquoted
      end

      def to_s
        quote_by_default ? quoted : unquoted
      end

      alias to_str to_s

      def to_sym
        unquoted.to_sym
      end

      alias to_symbol to_sym

      # Return another instance with new options
      #
      # @return [Support::Migrations::QuotableRef]
      def with(**new_options)
        opts = initializer_options.merge(new_options)

        self.class.new(root, **opts)
      end

      private

      memoize def initializer_options
        self.class.dry_initializer.options.to_h do |option|
          [option.source, __send__(option.target)]
        end
      end

      def compile
        [prefix, root, suffix].compact_blank.join(?_)
      end

      # @param [String] value
      # @return [String]
      def quote(value)
        # :nocov:
        connection.quote(value)
        # :nocov:
      end
    end
  end
end

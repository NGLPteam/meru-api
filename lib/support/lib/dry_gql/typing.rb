# frozen_string_literal: true

module Support
  module DryGQL
    class Typing < Support::FlexibleStruct
      attribute :actual_type, Types::TypeReference
      attribute :loads, Types::TypeReference.optional.default(nil).fallback(nil)

      attribute? :array, Types::Bool.default(false)
      attribute? :array_member_null, Types::Bool.default(false)
      attribute? :description, Types::String.optional.default(nil).fallback(nil)
      attribute? :required, Types::Bool.default(false).fallback(false)
      attribute? :replace_null, Types::Bool.default(false).fallback(false)

      attribute? :default_value, Types::Any.optional.default(nil)
      attribute? :has_default_value, Types::Bool.default(false).fallback(false)

      alias has_default_value? has_default_value

      alias replace_null_with_default replace_null

      # @return [Class<GraphQL::Schema::Member>]
      # @return [String] a string reference to a GraphQL object class, for lazy-loading.
      # @return [(Class<GraphQL::Schema::Member>, Hash)]
      # @return [(String, Hash)] a string reference to a GraphQL object class, for lazy-loading.
      attr_reader :type

      def initialize(...)
        super

        @type = realize_type
      end

      def as_array
        self.class.new(attributes.merge(array: true))
      end

      def argument_options
        opts = { type:, required: }

        if has_default_value?
          opts.merge!(default_value:, replace_null_with_default:)
        end

        if loads.present?
          opts[:loads] = loads.kind_of?(String) ? loads.constantize : loads
        end

        opts[:description] = description if description.present?

        return opts
      end

      def input_key_for(base)
        return base.to_sym unless loads

        array ? :"#{base}_ids" : :"#{base}_id"
      end

      private

      # @return [Object] (@see #type) the actual type declaration to be used in GraphQL argument definitions.
      def realize_type
        return actual_type unless array

        array_options = { null: array_member_null }

        return [actual_type, array_options]
      end
    end
  end
end

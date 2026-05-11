# frozen_string_literal: true

module Support
  module Filtering
    # A simple container for storing filter-scope arguments, which are dry-types
    # that have metadata about how to build their corresponding GQL definitions.
    class Arguments
      include Dry::Container::Mixin

      # @param [#to_s] key
      # @param [#to_s, Class, (Class)] type_key
      # @param [Hash] options
      # @return [Support::DryGQL::Types::Type]
      def add!(key, type_key, **options, &)
        type = Common::Container["filtering.type_container"].resolve(type_key)

        configured_type = ::Support::Filtering::ArgumentBuilder.new(type, **options).call(&)

        register key, configured_type

        recalculate_default_value!

        return configured_type
      end

      # @!attribute [r] default_value
      # @return [Hash{Symbol => Support::DryGQL::Typing}]
      def default_value
        @default_value ||= calculate_default_value
      end

      # @api private
      # @return [void]
      def recalculate_default_value!
        @default_value = calculate_default_value
      end

      private

      # @return [Hash{Symbol => Support::DryGQL::Typing}]
      def calculate_default_value
        each.each_with_object({}.with_indifferent_access) do |(key, type), defaults|
          typing = type.gql_typing

          next unless typing.has_default_value?

          defaults[key] = typing.default_value
        end
      end
    end
  end
end

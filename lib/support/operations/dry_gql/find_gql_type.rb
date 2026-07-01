# frozen_string_literal: true

module Support
  module DryGQL
    class FindGQLType
      TEST_ARRAY = [].freeze

      TEST_DATE = Date.current

      TEST_TIME = Time.current

      # @return [Class<GraphQL::Schema::Member>]
      # @return [String] a string reference to a GraphQL object class, for lazy-loading.
      def call(input)
        case input
        when :bool, :boolean then ::GraphQL::Types::Boolean
        when :bigint then ::GraphQL::Types::BigInt
        when :date then ::GraphQL::Types::ISO8601Date
        when :float then ::GraphQL::Types::Float
        when :id then ::GraphQL::Types::ID
        when :int, :integer then ::GraphQL::Types::Int
        when :string then ::GraphQL::Types::String
        when :time then ::GraphQL::Types::ISO8601DateTime
        when Types::SchemaMember then input
        when Types::LazyLoadTypeName
          input.sub(/\A(?!::)/, "::")
        when ::Dry::Types::Type
          find_primitive_for input
        else
          # simplecov:disable
          raise "Unknown GQL type reference: #{input.inspect}"
          # simplecov:enable
        end
      end

      private

      # @param [Dry::Types::Type] input
      def find_primitive_for(input)
        if input.primitive?(TEST_ARRAY)
          find_primitive_for(input.member)
        elsif input.primitive?(true) && input.primitive?(false)
          call(:boolean)
        elsif input.primitive?(0.0)
          call(:float)
        elsif input.primitive?(TEST_DATE)
          call(:date)
        elsif input.primitive?(1)
          call(:int)
        elsif input.primitive?("")
          call(:string)
        elsif input.primitive?(TEST_TIME)
          call(:time)
        else
          raise "Cannot derive primitive type for #{input.inspect}"
        end
      end
    end
  end
end

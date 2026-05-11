# frozen_string_literal: true

module Support
  module DryGQL
    class OrderEnumIntrospector
      include Dry::Core::Memoizable
      include Dry::Initializer[undefined: false].define -> do
        param :enum, Support::DryGQL::Types::EnumType
      end

      ORDER_PRIORITY = %w[DEFAULT RECENT].freeze

      delegate :value, allow_nil: true, prefix: :default, to: :default

      # @!attribute [r] default
      # @return [GraphQL::Schema::EnumValue, nil]
      memoize def default
        ORDER_PRIORITY.each do |key|
          value = enum.values[key]

          return value if value.present?
        end

        enum.values.first.second
      end
    end
  end
end

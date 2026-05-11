# frozen_string_literal: true

module Support
  module GQL
    # @see ::Support::Filtering::Inputs::IntegerMatch
    class FilterMatchIntegerType < ::Support::GQL::BaseFilterMatchObject
      struct_klass_name "Support::Filtering::Inputs::IntegerMatch"

      field :eq, GraphQL::Types::Int, null: true do
        description "Value to compare with using the `eq` operator."
      end

      field :not_eq, GraphQL::Types::Int, null: true do
        description "Value to compare with using the `not_eq` operator."
      end

      field :lt, GraphQL::Types::Int, null: true do
        description "Value to compare with using the `lt` operator."
      end

      field :lteq, GraphQL::Types::Int, null: true do
        description "Value to compare with using the `lteq` operator."
      end

      field :gt, GraphQL::Types::Int, null: true do
        description "Value to compare with using the `gt` operator."
      end

      field :gteq, GraphQL::Types::Int, null: true do
        description "Value to compare with using the `gteq` operator."
      end
    end
  end
end

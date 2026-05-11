# frozen_string_literal: true

module Support
  module GQL
    # @see ::Support::Filtering::Inputs::IntegerMatch
    class FilterMatchIntegerInputType < ::Support::GQL::BaseFilterMatchInputObject
      struct_klass_name "Support::Filtering::Inputs::IntegerMatch"

      argument :eq, Int, required: false do
        description "Value to compare with using the `eq` operator."
      end

      argument :not_eq, Int, required: false do
        description "Value to compare with using the `not_eq` operator."
      end

      argument :lt, Int, required: false do
        description "Value to compare with using the `lt` operator."
      end

      argument :lteq, Int, required: false do
        description "Value to compare with using the `lteq` operator."
      end

      argument :gt, Int, required: false do
        description "Value to compare with using the `gt` operator."
      end

      argument :gteq, Int, required: false do
        description "Value to compare with using the `gteq` operator."
      end
    end
  end
end

# frozen_string_literal: true

module Support
  module GQL
    # @see ::Support::Filtering::Inputs::FloatMatch
    class FilterMatchFloatInputType < ::Support::GQL::BaseFilterMatchInputObject
      struct_klass_name "Support::Filtering::Inputs::FloatMatch"

      argument :eq, Float, required: false do
        description "Value to compare with using the `eq` operator."
      end

      argument :not_eq, Float, required: false do
        description "Value to compare with using the `not_eq` operator."
      end

      argument :lt, Float, required: false do
        description "Value to compare with using the `lt` operator."
      end

      argument :lteq, Float, required: false do
        description "Value to compare with using the `lteq` operator."
      end

      argument :gt, Float, required: false do
        description "Value to compare with using the `gt` operator."
      end

      argument :gteq, Float, required: false do
        description "Value to compare with using the `gteq` operator."
      end
    end
  end
end

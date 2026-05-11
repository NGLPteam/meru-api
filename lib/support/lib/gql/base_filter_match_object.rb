# frozen_string_literal: true

module Support
  module GQL
    # @abstract For input objects that represent filtering options.
    # @see Support::Filtering::Inputs::ComparatorMatch
    class BaseFilterMatchObject < ::Support::GQL::BaseObject
      include ::Support::Filtering::SetsStructKlass

      description <<~TEXT
      A value with various constraints. If no values are provided to any
      operator, this filter will be ignored.
      TEXT
    end
  end
end

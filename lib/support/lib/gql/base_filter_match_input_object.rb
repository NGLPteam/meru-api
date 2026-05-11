# frozen_string_literal: true

module Support
  module GQL
    # @abstract For input objects that represent filtering options.
    # @see Support::Filtering::Inputs::ComparatorMatch
    class BaseFilterMatchInputObject < ::Support::GQL::BaseInputObject
      include ::Support::Filtering::SetsStructKlass

      description <<~TEXT
      Filter a value with various constraints. If no values are provided to any
      operator, this filter will be ignored.

      **Note**: The server will _not_ try to check for logical impossibilities,
      e.g. `{ lt: 5, gteq: 10 }`. Input like this will match nothing.
      TEXT

      # @return [Support::Filtering::Inputs::ComparatorMatch, nil]
      def prepare = struct_klass.new(to_h).presence
    end
  end
end

# frozen_string_literal: true

module Support
  module FullTextSearching
    module Types
      extend Support::Typespace

      Attribute = Coercible::Symbol.constrained(format: /\A[a-z_][a-z0-9_]*\z/)

      ColumnName = Attribute

      ColumnNames = Types::Array.of(ColumnName).constrained(min_size: 1)

      ContextName = Attribute

      Needle = Coercible::String.optional

      ScopeName = Attribute

      # @see Support::GQL::SearchStrategyType
      Strategy = Coercible::String.enum("exact", "fuzzy", "prefix").fallback("fuzzy")
    end
  end
end

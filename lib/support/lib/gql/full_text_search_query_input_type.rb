# frozen_string_literal: true

module Support
  module GQL
    # @see Support::FullTextSearching::Query
    class FullTextSearchQueryInputType < ::Support::GQL::BaseInputObject
      description <<~TEXT
      An input object representing the parameters for a full-text search query.
      TEXT

      argument :needle, String, required: false do
        description <<~TEXT
        The query to search by.
        TEXT
      end

      argument :strategy, ::Support::GQL::FullTextSearchStrategyType, required: false, default_value: "fuzzy", replace_null_with_default: true do
        description <<~TEXT
        The search strategy to use, either "PREFIX" for prefix matching or "FUZZY" for fuzzy query matching.
        TEXT
      end

      # @return [Support::FullTextSearching::Query]
      def prepare = ::Support::FullTextSearching::Query.from(to_h)
    end
  end
end

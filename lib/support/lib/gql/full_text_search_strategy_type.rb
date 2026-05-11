# frozen_string_literal: true

module Support
  module GQL
    class FullTextSearchStrategyType < ::Support::GQL::BaseEnum
      description <<~TEXT
      The strategy to use for full-text search queries.
      TEXT

      value "EXACT", value: "exact" do
        description <<~TEXT
        This will look for an exact match of the provided needle.
        TEXT
      end

      value "FUZZY", value: "fuzzy" do
        description <<~TEXT
        This uses a "fuzzy" full-text websearch strategy,
        which supports using quotation marks and negation.
        TEXT
      end

      value "PREFIX", value: "prefix" do
        description <<~TEXT
        This will try to match beginnings of words in the provided needle.
        TEXT
      end
    end
  end
end

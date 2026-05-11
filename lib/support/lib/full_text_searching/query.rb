# frozen_string_literal: true

module Support
  module FullTextSearching
    # A struct representing the parameters for a full-text search query.
    #
    # @see ::Support::GQL::FullTextSearchStrategyType
    # @see ::Support::GQL::FullTextSearchQueryInputType
    class Query < Support::FlexibleStruct
      include Dry::Matcher.for(:apply, with: FullTextSearching::Matcher)
      include Support::Typing

      with_gql_type! ::Support::GQL::FullTextSearchQueryInputType

      attribute :needle, Types::Needle

      attribute? :strategy, Types::Strategy

      def apply = self

      def empty? = needle.blank?

      def exact? = strategy == "exact"

      def fuzzy? = strategy == "fuzzy"

      def prefix? = strategy == "prefix"

      def ranked_by_relevance? = present? && (fuzzy? || prefix?)

      class << self
        # @param [FullTextSearching::Query, String, Hash] input the input to convert to a `FullTextSearching::Query` instance
        # @param ["fuzzy", "prefix"] strategy the default search strategy to use when the input is a string or hash without a specified strategy
        # @return [FullTextSearching::Query] a `FullTextSearching::Query` instance representing the provided input
        def from(input, strategy: "fuzzy")
          case input
          when self then input
          when String then new(needle: input, strategy:)
          when Hash then new(strategy:, **input)
          else
            raise ArgumentError, "Cannot convert #{input.inspect} to #{self}"
          end
        end
      end
    end
  end
end

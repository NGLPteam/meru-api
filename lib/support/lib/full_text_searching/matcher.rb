# frozen_string_literal: true

module Support
  module FullTextSearching
    fuzzy = Dry::Matcher::Case.new do |value|
      if value.fuzzy? && value.present?
        value.needle
      else
        Dry::Matcher::Undefined
      end
    end

    prefix = Dry::Matcher::Case.new do |value|
      if value.prefix? && value.present?
        value.needle
      else
        Dry::Matcher::Undefined
      end
    end

    exact = Dry::Matcher::Case.new do |value|
      if value.exact? && value.present?
        value.needle
      else
        Dry::Matcher::Undefined
      end
    end

    empty = Dry::Matcher::Case.new do |value|
      if value.empty?
        nil
      else
        Dry::Matcher::Undefined
      end
    end

    # A matcher for determing the appropriate search strategy to use,
    # based on the properties of a {::Support::FullTextSearching::Query} instance.
    #
    # @api private
    # @see ::Support::FullTextSearching::Query
    Matcher = Dry::Matcher.new(exact:, fuzzy:, prefix:, empty:)
  end
end

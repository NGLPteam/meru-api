# frozen_string_literal: true

module JournalSources
  module Parsers
    class Full < JournalSources::Parsers::Abstract
      parsed_klass JournalSources::Parsed::Full

      PATTERNS = [
        /\A.+?; Volume (?<volume>\d+), Number (?<issue>\d+)(?:; (?<fpage>\d+)(?:.+?(?<lpage>\d+))?)?\z/,
        /\A.+?; Vol\.?? (?<volume>\d+),?? No\.?? (?<issue>\d+(?:-\d+)?) \((?<year>\d+)\)(?:; (?<fpage>\d+)(?:[^\d](?<lpage>\d+))?)?\z/,
        # "Special edition" issues", e.g. `Vol 50, No SE`
        /\A.+?; Vol\.?? (?<volume>\d+),?? No\.?? (?<issue>\S+) \((?<year>\d+)\)(?:; (?<fpage>\d+)(?:[^\d](?<lpage>\d+))?)?\z/,
        /\A.+?, vol (?<volume>\d+), iss (?<issue>\d+)\z/,
      ].freeze

      ENDS_WITH_SINGLE_PAGE = /; \d+\z/

      def try_parsing!(input)
        if ENDS_WITH_SINGLE_PAGE.match?(input)
          try_parsing_with_patterns!(input)

          # :nocov:
          # A fallback for inputs that do not match any of the patterns
          try_anystyle!(input)
          # :nocov:
        else
          try_anystyle!(input)

          try_parsing_with_patterns!(input)
        end
      end

      # @param [String] input
      # @return [void]
      def try_parsing_with_patterns!(input)
        PATTERNS.each do |pattern|
          match = pattern.match input

          # :nocov:
          next unless match
          # :nocov:

          try_parsing_with_pattern_match!(input, match)
        end
      end

      # @param [String] input
      # @param [MatchData] match
      # @param [{ Symbol => Object }] extra
      # @return [void]
      def try_parsing_with_pattern_match!(input, match, **extra)
        attrs = { input: }.merge(match.named_captures.symbolize_keys).merge(**extra)

        check_parsed!(**attrs)
      end
    end
  end
end

# frozen_string_literal: true

module JournalSources
  class Parse
    include Dry::Monads[:maybe]
    include Dry::Matcher.for(:call, with: ::JournalSources::Matcher)

    include MeruAPI::Deps[
      parse_full: "journal_sources.parsers.full",
      parse_issue_only: "journal_sources.parsers.issue_only",
      parse_volume_only: "journal_sources.parsers.volume_only",
      parse_fallback: "journal_sources.parsers.fallback",
    ]

    def call(*inputs)
      parse_full.(*inputs).or do
        parse_volume_only.(*inputs).or do
          parse_issue_only.(*inputs).or do
            parse_fallback.(*inputs)
          end
        end
      end.value_or do
        JournalSources::Parsed::Unknown.new
      end
    end
  end
end

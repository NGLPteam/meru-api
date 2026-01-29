# frozen_string_literal: true

module JournalSources
  module Parsers
    class IssueOnly < JournalSources::Parsers::Abstract
      parsed_klass JournalSources::Parsed::IssueOnly

      def try_parsing!(input)
        try_anystyle! input
      end
    end
  end
end

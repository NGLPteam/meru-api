# frozen_string_literal: true

module JournalSources
  module Parsed
    # @see JournalSources::ParseIssueOnly
    class IssueOnly < ::JournalSources::Parsed::Abstract
      mode :issue_only
    end
  end
end

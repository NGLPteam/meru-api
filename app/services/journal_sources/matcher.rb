# frozen_string_literal: true

module JournalSources
  # @api private
  FullCase = Dry::Matcher::Case.new do |parsed, *|
    if parsed.kind_of?(JournalSources::Parsed::Abstract) && parsed.full? && parsed.known?
      parsed
    else
      # :nocov:
      Dry::Matcher::Undefined
      # :nocov:
    end
  end

  # @api private
  VolumeOnlyCase = Dry::Matcher::Case.new do |parsed, *|
    if parsed.kind_of?(JournalSources::Parsed::Abstract) && parsed.volume_only? && parsed.known?
      parsed
    else
      # :nocov:
      Dry::Matcher::Undefined
      # :nocov:
    end
  end

  IssueOnlyCase = Dry::Matcher::Case.new do |parsed, *|
    if parsed.kind_of?(JournalSources::Parsed::Abstract) && parsed.issue_only? && parsed.known?
      parsed
    else
      # :nocov:
      Dry::Matcher::Undefined
      # :nocov:
    end
  end

  # @api private
  UnknownCase = Dry::Matcher::Case.new do |parsed, *|
    if parsed.kind_of?(JournalSources::Parsed::Abstract) && parsed.known?
      # :nocov:
      Dry::Matcher::Undefined
      # :nocov:
    else
      parsed
    end
  end

  Matcher = Dry::Matcher.new(
    full: FullCase,
    volume_only: VolumeOnlyCase,
    issue_only: IssueOnlyCase,
    unknown: UnknownCase,
  )
end

# frozen_string_literal: true

module JournalSources
  # A Liquid drop for an instance of {JournalSources::Parsed::Abstract}
  class Drop < ::Liquid::Drop
    include Dry::Matcher.for(:match_journal_source, with: ::JournalSources::Matcher)

    # @param [JournalSources::Parsed::Abstract] journal_source
    def initialize(journal_source = nil)
      @journal_source = journal_source

      @mode = JournalSources::Types::LiquidMode[@journal_source.try(:mode)]

      @exists = @journal_source.try(:known?).present?

      match_journal_source do |m|
        m.full do |parsed|
          @volume = parsed.volume
          @issue = parsed.issue
        end

        m.volume_only do |parsed|
          @volume = parsed.volume
          @issue = nil
        end

        m.issue_only do |parsed|
          @volume = nil
          @issue = parsed.issue
        end

        m.unknown do
          @volume = @issue = nil
        end
      end
    end

    # @return [Boolean]
    attr_reader :exists

    alias known exists

    alias exists? exists

    alias known? known

    # @!attribute [r] full
    # @return [Boolean]
    def full = mode == "full"

    alias full? full

    # @return [String, nil]
    attr_reader :issue

    # @!attribute [r] issue_only
    # @return [Boolean]
    def issue_only = mode == "issue_only"

    alias issue_only? issue_only

    # @return [JournalSources::Types::LiquidMode]
    attr_reader :mode

    # @!attribute [r] unknown
    # @return [Boolean]
    def unknown = mode == "unknown"

    alias unknown? unknown

    # @return [String, nil]
    attr_reader :volume

    # @return [Boolean]
    def volume_only = mode == "volume_only"

    alias volume_only? volume_only

    private

    def match_journal_source
      @journal_source
    end
  end
end

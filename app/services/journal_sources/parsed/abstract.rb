# frozen_string_literal: true

module JournalSources
  module Parsed
    # @abstract
    class Abstract < ::Support::FlexibleStruct
      include ActiveModel::Validations
      include Dry::Core::Constants
      include Dry::Monads[:maybe]
      include Dry::Matcher.for(:matched, with: ::JournalSources::Matcher)
      include JournalSources::Types

      extend Dry::Core::ClassAttributes

      UNKNOWN = JournalSources::Types::UNKNOWN

      defines :mode, type: Types::Mode

      mode :unknown

      attribute? :input, Types::KnowableString

      attribute? :volume, Types::KnowableString
      attribute? :issue, Types::KnowableString

      attribute? :journal, Types::OptionalString

      attribute? :year, Types::OptionalInteger
      attribute? :fpage, Types::OptionalInteger
      attribute? :lpage, Types::OptionalInteger

      validates :volume, presence: true, comparison: { other_than: UNKNOWN }, if: :has_required_volume?

      validates :issue, presence: true, comparison: { other_than: UNKNOWN }, if: :has_required_issue?

      # @return [JournalSources::Drop]
      def to_liquid = JournalSources::Drop.new(self)

      # @return [Dry::Monads::Some(JournalSources::Parsed::Abstract), Dry::Monads::None]
      def to_monad = valid? ? Some(self) : None()

      # @!group Mode Logic

      def full? = mode == :full

      def known? = !unknown? && valid?

      def has_required_issue? = full? || issue_only?

      def has_required_volume? = full? || volume_only?

      def issue_only? = mode == :issue_only

      # @return [JournalSources::Types::Mode]
      def mode = self.class.mode

      def unknown? = mode == :unknown || invalid?

      def volume_only? = mode == :volume_only

      # @!endgroup Mode Logic
    end
  end
end

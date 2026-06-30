# frozen_string_literal: true

require "test_prof/ext/active_record_refind"

using TestProf::Ext::ActiveRecordRefind

module TestHelpers
  module JournalHierarchy
    class NestedIterator
      extend Dry::Core::ClassAttributes

      include Dry::Core::Constants
      include Dry::Core::Memoizable
      include Enumerable

      defines :child_count, type: Support::Types::Integer.constrained(gt: 0)
      defines :child_iter_klass, type: Support::Types::Class.optional
      defines :identifier_name, type: Support::Types::Coercible::String.optional
      defines :leaf, :root, type: Support::Types::Bool

      child_count 2

      child_iter_klass TestHelpers::JournalHierarchy::NestedIterator

      identifier_name nil

      root false
      leaf false

      include Dry::Initializer[undefined: false].define -> do
        option :index, Support::Types::Integer.optional, optional: true

        option :parent, Support::Types.Instance(TestHelpers::JournalHierarchy::NestedIterator).optional, optional: true
      end

      delegate :identifier, to: :parent, prefix: true, allow_nil: true

      delegate :identifier_name, :child_count, :child_iter_klass, to: :class

      def all_identifiers
        [
          identifier,
        ].compact + flat_map(&:all_identifiers)
      end

      def deconstruct
        [index, identifier]
      end

      def deconstruct_keys(_)
        { index:, identifier:, }
      end

      memoize def children
        return EMPTY_ARRAY if self.class.leaf

        1.upto(child_count).map do |index|
          child_iter_klass.new(index:, parent: self)
        end
      end

      def each(&)
        return enum_for(__method__) unless block_given?

        children.each(&)
      end

      # @return [Symbol, nil]
      memoize def identifier
        return if self.class.root || index.blank? || self.class.identifier_name.blank?

        [parent_identifier, identifier_name, index].compact_blank.join(?_).to_sym
      end
    end

    class ArticleIterator < NestedIterator
      identifier_name :article

      leaf true
    end

    class IssueIterator < NestedIterator
      identifier_name :issue

      child_count 2

      child_iter_klass ArticleIterator
    end

    class VolumeIterator < NestedIterator
      identifier_name :volume

      child_count 3

      child_iter_klass IssueIterator
    end

    class JournalIterator < NestedIterator
      root true

      child_iter_klass VolumeIterator

      class << self
        def instance
          @instance ||= new
        end

        delegate_missing_to :instance
      end
    end

    module RefreshJournalFixture
      def refresh_journal_fixture(entity)
        entity.tap do
          entity.reload
          entity.refresh_orderings!
          entity.render_layouts!
        end
      end
    end

    module SpecHelpers
      include RefreshJournalFixture
    end

    module ExampleHelpers
      include RefreshJournalFixture
    end
  end
end

RSpec.shared_context "journal hierarchy" do
  extend TestHelpers::JournalHierarchy::SpecHelpers

  include TestHelpers::JournalHierarchy::ExampleHelpers

  let_it_be(:base_journal_community) do
    Schemas::Orderings.with_disabled_refresh do
      FactoryBot.create(:community, :with_logo, :with_thumbnail, identifier: "journal-community", title: "Base Journal Community").tap(&:reload)
    end
  end

  let_it_be(:base_journal) do
    Schemas::Orderings.with_disabled_refresh do
      FactoryBot.create(:collection, community: base_journal_community, schema: "nglp:journal").tap(&:reload)
    end
  end

  jiter = TestHelpers::JournalHierarchy::JournalIterator.new

  jiter.each do |viter|
    viter => { index: vnum, identifier: vid }

    let_it_be(:"base_#{vid}") do
      identifier = vid
      title = "Volume #{vnum}"

      pending_properties = {
        number: vnum.to_s,
        sortable_number: vnum,
      }

      Schemas::Orderings.with_disabled_refresh do
        FactoryBot.create(:collection, schema: "nglp:journal_volume", community: base_journal_community, parent: base_journal, title:, identifier:, pending_properties:).tap(&:reload)
      end
    end

    viter.each do |iiter|
      iiter => { index: inum, identifier: iid }

      let_it_be(:"base_#{iid}") do
        identifier = iid
        title = "Issue #{inum}"

        pending_properties = {
          number: inum.to_s,
          sortable_number: inum.to_s,
          volume: {
            sortable_number: vnum,
          },
        }

        Schemas::Orderings.with_disabled_refresh do
          FactoryBot.create(:collection, schema: "nglp:journal_issue", community: base_journal_community, parent: __send__(:"base_#{vid}"), title:, identifier:, pending_properties:).tap(&:reload)
        end
      end

      iiter.each do |aiter|
        aiter => { index: anum, identifier: aid }

        let_it_be(:"base_#{aid}") do
          identifier = aid.to_s

          title = "Article #{anum}"

          pending_properties = {
            abstract: Faker::Lorem.paragraph,
            citation: Faker::Lorem.paragraph,
            preprint_version: false,
            volume: {
              sortable_number: vnum,
            },
            issue: {
              sortable_number: inum,
            },
            meta: {
              collected: VariablePrecisionDate.parse(2022),
              page_count: 2,
            }
          }

          Schemas::Orderings.with_disabled_refresh do
            FactoryBot.create(:item, schema: "nglp:journal_article", collection: __send__(:"base_#{iid}"), title:, identifier:, pending_properties:).tap(&:reload)
          end
        end
      end
    end
  end

  let_it_be(:journal_community, refind: true) { refresh_journal_fixture(base_journal_community) }
  let_it_be(:journal, refind: true) { refresh_journal_fixture(base_journal) }

  TestHelpers::JournalHierarchy::JournalIterator.all_identifiers.each do |identifier|
    let_it_be(identifier, refind: true) { refresh_journal_fixture(__send__(:"base_#{identifier}")) }
  end

  let_it_be(:journal_entities) do
    [
      journal_community,
      journal,
    ] + TestHelpers::JournalHierarchy::JournalIterator.all_identifiers.map do |identifier|
      __send__(identifier)
    end
  end
end

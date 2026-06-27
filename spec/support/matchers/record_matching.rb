# frozen_string_literal: true

module RecordMatching
  module Types
    extend Support::Typespace

    KnownMatchingMode = Coercible::Symbol.default(:inclusion).enum(:inclusion, :exclusion, :exact)

    RecordName = Support::Types::Coercible::Symbol

    RecordNames = Support::Types::Array.of(RecordName)

    RecordVisibility = Support::Types::Symbol.default(:included).enum(:included, :excluded, :ignored)

    RecordOptions = Support::Types::Hash.schema(
      visibility?: RecordVisibility
    )

    RecordsMap = Support::Types::Hash.map(RecordName, RecordOptions)
  end

  class KnownRecord < Support::FlexibleStruct
    include Dry::Core::Equalizer.new(:name)

    include Support::Typing

    attribute :name, Types::RecordName
    attribute :visibility, Types::RecordVisibility

    def excluded? = visibility == :excluded

    def included? = visibility == :included
  end

  module RecordInspection
    def inspect_record(record) = Support::Inspector.inspect(record)

    def inspect_scope(scope)
      if scope.is_a?(ActiveRecord::Relation)
        "scope of #{scope.klass.name} with #{scope.where_values_hash.inspect} conditions"
      else
        "array of records: #{scope.map { |r| inspect_record(r) }.join(", ")}"
      end
    end
  end

  module KnownRecordHelpers
    extend ActiveSupport::Concern

    included do
      extend Dry::Core::ClassAttributes

      defines :known_records_map, type: Types::RecordsMap

      defines :known_records, type: RecordMatching::KnownRecord::List

      defines :record_matching_mode, type: Types::KnownMatchingMode

      record_matching_mode :inclusion

      known_records_map Dry::Core::Constants::EMPTY_HASH

      known_records Dry::Core::Constants::EMPTY_ARRAY
    end

    def find_included_records = known_records_for(&:included?)

    def find_excluded_records = known_records_for(&:excluded?)

    # @!attribute [r] known_records
    # @return [<RecordMatching::KnownRecord>] the list of known records with their visibility
    def known_records = self.class.known_records

    # @return [<ApplicationRecord>]
    def known_records_for(&)
      raise "must provide a block" unless block_given?

      known = known_records.select(&)

      known.flat_map do |record|
        __send__(record.name)
      end
    end

    def match_known_records(mode: record_matching_mode)
      case RecordMatching::Types::KnownMatchingMode[mode]
      in :exact
        match_records.containing_exactly(find_included_records)
      in :exclusion
        match_records.excluding(*find_included_records)
      in :empty
        match_no_records
      else
        match_records.including(*find_included_records).excluding(*find_excluded_records)
      end
    end

    # @return [:inclusion, :exclusion, :exact]
    def record_matching_mode = self.class.record_matching_mode

    module ClassMethods
      def ignore_records!(*record_names)
        mapping = map_record_names(*record_names, visibility: :ignored)

        known_records!(_clear: false, **mapping)
      end

      # @param [<Symbol>] record_names
      # @return [void]
      def include_records!(*record_names, _clear: false)
        mapping = map_record_names(*record_names, visibility: :included)

        known_records!(_clear:, **mapping)
      end

      def exclude_records!(*record_names, _clear: false)
        mapping = map_record_names(*record_names, visibility: :excluded)

        known_records!(_clear:, **mapping)
      end

      # @param [{ RecordName => RecordVisibility, RecordOptions, Boolean, nil }] mapping
      # @return [void]
      def known_records!(_clear: false, **mapping)
        new_records_map = mapping.transform_values do |input|
          known_record_options_for(input)
        end

        new_known_records_map = _clear ? new_records_map : known_records_map.merge(new_records_map)

        known_records_map new_known_records_map.freeze

        new_known_records = new_known_records_map.map do |name, options|
          RecordMatching::KnownRecord.new(name:, **options)
        end

        known_records new_known_records
      end

      # @return [void]
      def exclude_known_records!
        record_matching_mode :exclusion
      end

      # @return [void]
      def include_known_records!
        record_matching_mode :inclusion
      end

      # @return [void]
      def only_known_records!
        record_matching_mode :exact
      end

      def known_record_options_for(input)
        case input
        in RecordMatching::Types::RecordOptions then input
        in RecordMatching::Types::RecordVisibility => visibility then { visibility: }
        in true then { visibility: :included }
        in false then { visibility: :excluded }
        in nil then { visibility: :ignored }
        else
          raise ArgumentError, "Invalid record visibility value: #{input.inspect}"
        end
      end

      private

      # @param [<#to_sym>] record_names
      # @return [<Symbol>]
      def enforce_record_names(*record_names)
        record_names.flatten.map { RecordMatching::Types::RecordName[_1] }.sort.uniq
      end

      # @return [{ RecordName => RecordOptions }]
      def map_record_names(*record_names, visibility:)
        enforce_record_names(*record_names).index_with { { visibility: } }
      end
    end
  end

  # A safeguard for {RecordsMatcher} to ensure that inconsistent options can't be used.
  class EnumerableMachine
    include Statesman::Machine

    state :unset, initial: true
    state :exact
    state :fuzzy
    state :count

    transition from: :unset, to: :exact
    transition from: :unset, to: :fuzzy
    transition from: :unset, to: :count

    transition from: :count, to: :count
    transition from: :exact, to: :exact
    transition from: :fuzzy, to: :fuzzy
  end

  # This custom matcher is exposed as `match_records` and can be used to test
  # that a given enumerable "scope" (`ActiveRecord::Relation` **or** an array of records)
  # includes or excludes specific records. It provides a slightly
  # more descriptive failure message that won't dump a dozen
  # records if the scope doesn't match.
  class RecordsMatcher
    include RecordMatching::RecordInspection
    include RSpec::Matchers::Composable

    def initialize
      @machine = EnumerableMachine.new(self)

      @excluded = Set.new
      @included = Set.new
      @exclusive = Set.new
      @expected_count = nil

      @missing_inclusions = []
      @unexpected_inclusions = []
    end

    # @return [ActiveRecord::Relation, Array, #include?]
    attr_reader :scope

    def containing_exactly(*records)
      records.flatten!

      set_mode!(:exact)

      @exclusive.merge(records)

      self
    end

    # @param [<ApplicationRecord>] records
    # @return [void]
    def including(*records)
      records.flatten!

      set_mode!(:fuzzy)

      @included.merge(records)
      @excluded.subtract(records)

      self
    end

    # @param [<ApplicationRecord>] records
    # @return [void]
    def excluding(*records)
      records.flatten!

      set_mode!(:fuzzy)

      @excluded.merge(records)
      @included.subtract(records)

      self
    end

    def with_count(number)
      set_mode!(:count)

      @expected_count = number

      self
    end

    def empty = with_count(0)

    def has_any_constraints?
      case current_state
      in "fuzzy"
        @included.any? || @excluded.any?
      in "exact"
        @exclusive.any?
      in "count"
        !@expected_count.nil?
      else
        false
      end
    end

    def has_no_constraints? = !has_any_constraints?

    # @param [Enumerable]
    # @return [Boolean]
    def match(scope)
      raise "No constraints specified for collection matcher" if has_no_constraints?

      @scope = scope

      case current_state
      in "count"
        check_count_match
      in "exact"
        check_exact_match
      in "fuzzy"
        check_fuzzy_match
      end
    end

    alias matches? match

    def description
      parts = []

      case current_state
      in "count"
        if @expected_count == 0
          parts << "be empty"
        else
          parts << "have count #{@expected_count}"
        end
      in "exact"
        parts << "contain exactly #{@exclusive.map { |r| inspect_record(r) }.join(", ")}"
      in "fuzzy"
        parts << "include #{@included.map { |r| inspect_record(r) }.join(", ")}" if @included.any?
        parts << "exclude #{@excluded.map { |r| inspect_record(r) }.join(", ")}" if @excluded.any?
      end

      "be a scope of records that #{parts.join(" and ")}"
    end

    def failure_message
      lines = ["expected records to satisfy constraints"]
      lines << "  defined as: #{inspect_scope(scope)}"

      case current_state
      in "count"
        if @expected_count == 0
          lines << "  expected to be empty, but had #{@actual_count} record(s)"
        else
          lines << "  expected count: #{@expected_count}, but got #{@actual_count}"
        end
      in "exact"
        if @missing_exclusives.any?
          lines << "  missing: #{@missing_exclusives.map { |r| inspect_record(r) }.join(", ")}"
        end

        if @unexpected_additional.any?
          lines << "  unexpected: #{@unexpected_additional.map { |r| inspect_record(r) }.join(", ")}"
        end
      in "fuzzy"
        if @missing_inclusions.any?
          lines << "  missing: #{@missing_inclusions.map { |r| inspect_record(r) }.join(", ")}"
        end

        if @unexpected_inclusions.any?
          lines << "  unexpected: #{@unexpected_inclusions.map { |r| inspect_record(r) }.join(", ")}"
        end
      end

      lines.join("\n")
    end

    def failure_message_when_negated
      "expected scope not to satisfy constraints, but it did"
    end

    private

    def check_count_match
      @actual_count = @scope.count

      @actual_count == @expected_count
    end

    # @return [Boolean]
    def check_exact_match
      found_records = @scope.limit(@exclusive.size * 2).to_a
      @missing_exclusives = @exclusive.reject { |record| record.in?(found_records) }
      @unexpected_additional = found_records - @exclusive.to_a

      @missing_exclusives.empty? && @unexpected_additional.empty?
    end

    # @return [Boolean]
    def check_fuzzy_match
      @missing_inclusions = @included.reject { |record| @scope.include?(record) }
      @unexpected_inclusions = @excluded.select { |record| @scope.include?(record) }

      @missing_inclusions.empty? && @unexpected_inclusions.empty?
    end

    def current_state = @machine.current_state

    def set_mode!(new_mode)
      @machine.transition_to!(new_mode)
    end
  end

  module MatcherMethods
    # Add `match_records` matcher for testing record collections.
    def match_records = RecordsMatcher.new

    def match_no_records = RecordsMatcher.new.empty
  end
end

RSpec.configure do |config|
  config.include RecordMatching::MatcherMethods
  config.include RecordMatching::KnownRecordHelpers, with_known_records: true
  config.extend RecordMatching::KnownRecordHelpers::ClassMethods, with_known_records: true
end

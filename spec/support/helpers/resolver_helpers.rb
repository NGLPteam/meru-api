# frozen_string_literal: true

require_relative "current_user_helpers"
require_relative "filter_scope_helpers"
require_relative "hash_setter"

module TestHelpers
  ContextValueHelpers = TestHelpers::HashSetter.new(:context_values)
  GraphQLArgumentHelpers = TestHelpers::HashSetter.new(:graphql_arguments)

  module Resolver
    module Types
      extend ::Support::Typespace

      Record = Any

      Records = Array.of(Any)

      Resolver = Instance(::Resolvers::AbstractResolver)

      OptionalCount = Integer.constrained(gteq: 0).optional
    end

    class ResolutionShape
      include Support::Typing
      include Dry::Initializer[undefined: false].define -> do
        option :included, Types::Records
        option :excluded, Types::Records
        option :total_count, Types::OptionalCount, optional: true
        option :total_unfiltered_count, Types::OptionalCount, optional: true
      end

      def total_count_matches?(value) = count_matches?(value, total_count)

      def total_unfiltered_count_matches?(value) = count_matches?(value, total_unfiltered_count)

      def validate!(resolver)
        validator = ResolutionValidator.new(self, resolver)

        validator.call
      end

      private

      def count_matches?(actual, expected)
        expected.nil? || expected === actual
      end
    end

    class ResolutionValidator
      include ActiveModel::Validations
      include Dry::Initializer[undefined: false].define -> do
        param :shape, ResolutionShape::Type
        param :resolver, Types::Resolver
      end

      validate :check_included_records!
      validate :check_excluded_records!
      validate :check_total_count!
      validate :check_total_unfiltered_count!

      # @return [<String>]
      def call
        valid?

        errors.full_messages
      end

      private

      # @return [void]
      def check_included_records!
        shape.included.each do |record|
          errors.add(:base, "Missing expected record #{record.inspect}") unless resolver.results.include?(record)
        end
      end

      # @return [void]
      def check_excluded_records!
        shape.excluded.each do |record|
          errors.add(:base, "Unexpected record included: #{record.inspect}") if resolver.results.include?(record)
        end
      end

      def check_total_count!
        return if shape.total_count_matches?(resolver.count)

        errors.add(:base, "Expected total count #{shape.total_count}, got #{resolver.count}")
      end

      def check_total_unfiltered_count!
        return if shape.total_unfiltered_count_matches?(resolver.unfiltered_count)

        errors.add(:base, "Expected total unfiltered count #{shape.total_unfiltered_count}, got #{resolver.unfiltered_count}")
      end
    end

    # @api private
    class ResolutionShaper
      def initialize
        @included = []
        @excluded = []
        @total_count = nil
        @total_unfiltered_count = nil
      end

      # @return [TestHelpers::Resolver::ResolutionShape]
      def configure(&)
        yield self

        return to_shape
      end

      # @return [void]
      def include!(*records)
        @included.concat(records).uniq!
      end

      # @return [void]
      def exclude!(*records)
        @excluded.concat(records).uniq!
      end

      def total_count!(count)
        @total_count = count
      end

      def total_unfiltered_count!(count)
        @total_unfiltered_count = count
      end

      # @return [TestHelpers::Resolver::ResolutionShape]
      def to_shape
        ResolutionShape.new(
          included: @included,
          excluded: @excluded,
          total_count: @total_count,
          total_unfiltered_count: @total_unfiltered_count
        )
      end
    end

    module ExampleHelpers
      extend RSpec::Matchers::DSL

      def build_shape(&)
        ResolutionShaper.new.configure(&)
      end

      matcher :match_shape do |shape|
        match do |resolver|
          # simplecov:disable
          raise TypeError, "Expected a ResolutionShape, got #{shape.class}" unless shape.kind_of?(TestHelpers::Resolver::ResolutionShape)
          raise TypeError, "Expected a Resolver, got #{resolver.class}" unless resolver.kind_of?(described_class)
          # simplecov:enable

          @errors = shape.validate!(resolver)

          @errors.blank?
        end

        description do
          "match the expected resolution shape"
        end

        failure_message do
          "Expected resolver to match shape, but the following errors were found:\n#{@errors.join("\n")}"
        end

        failure_message_when_negated do
          "Expected resolver not to match shape, but it did."
        end
      end
    end

    module SpecHelpers
      def expect_shape!(&)
        let(:expected_resolution_shape) { build_shape(&) }
      end
    end
  end
end

RSpec.shared_context "resolver tests" do
  let(:object) { nil }

  let(:filter_klass) { described_class.filter_scope_klass }

  let(:filters) { filter_klass.new(**filter_args) }

  let(:or_filters) { [] }

  let(:compiled_or_filters) do
    or_filters.map { filter_klass.new(**_1) }
  end

  let(:current_arguments) do
    graphql_arguments.merge(filters:, or_filters: compiled_or_filters)
  end

  let(:graphql_context) do
    Support::DryGQL::Types::BUILD_NULL_CONTEXT.(**context_values, current_arguments:, current_user:)
  end

  let(:options) do
    {
      object:,
      context: graphql_context,
    }
  end

  let(:included_records) { [] }
  let(:excluded_records) { [] }
  let(:expected_count) { nil }
  let(:expected_unfiltered_count) { nil }

  let(:expected_resolution_shape) do
    build_shape do |s|
      s.include!(*included_records)
      s.exclude!(*excluded_records)
      s.total_count!(expected_count)
      s.total_unfiltered_count!(expected_unfiltered_count)
    end
  end

  let!(:resolver_instance) do
    described_class.new(**options).tap { _1.resolve(**current_arguments) }
  end

  let(:resolver_params) do
    resolver_instance.params
  end

  let(:resolved_results) do
    resolver_instance.results
  end

  subject { resolver_instance }

  shared_examples_for "a full resolution" do
    it "matches the expected resolution shape" do
      is_expected.to match_shape(expected_resolution_shape)
    end
  end
end

RSpec.shared_examples_for "common resolver tests" do
  let(:expected_count_range) { 0... }
  let(:expected_unfiltered_count_range) { 0... }

  describe "#count" do
    it "returns an integer" do
      expect(subject.count).to match_integer(expected_count_range)
    end
  end

  describe "#unfiltered_count" do
    it "returns an integer" do
      expect(subject.unfiltered_count).to match_integer(expected_unfiltered_count_range)
    end
  end
end

RSpec.configure do |config|
  TestHelpers::CurrentUser.attach_to!(config, type: :resolver)

  config.include TestHelpers::ContextValueHelpers, type: :resolver
  config.include TestHelpers::FilterHelpers, type: :resolver
  config.include TestHelpers::GraphQLArgumentHelpers, type: :resolver

  config.include TestHelpers::Resolver::ExampleHelpers, type: :resolver
  config.include TestHelpers::Resolver::SpecHelpers, type: :resolver

  config.include_context "resolver tests", type: :resolver
end

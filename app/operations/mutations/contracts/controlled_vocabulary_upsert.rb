# frozen_string_literal: true

module Mutations
  module Contracts
    # @see Mutations::ControlledVocabularyUpsert
    # @see Mutations::Operations::ControlledVocabularyUpsert
    class ControlledVocabularyUpsert < MutationOperations::Contract
      json do
        required(:definition).hash do
          required(:namespace).value(ControlledVocabularies::Types::Namespace)
          required(:identifier).value(ControlledVocabularies::Types::Identifier)
          required(:provides).value(ControlledVocabularies::Types::Provides)
          required(:version).value(ControlledVocabularies::Types::Version)
          required(:name).value(ControlledVocabularies::Types::Name)
          optional(:description).maybe(:string)

          required(:items).array(:hash)
        end
      end

      rule(definition: :namespace) do
        key.failure("must not be default Meru namespace") if value == ControlledVocabulary::DEFAULT_NAMESPACE
      end

      rule(:definition) do
        # simplecov:disable
        next if result.errors.any?
        # simplecov:enable

        result = MeruAPI::Container["controlled_vocabularies.validate"].(value)

        Dry::Matcher::ResultMatcher.(result) do |m|
          m.success do
            # intentionally left blank
          end

          m.failure(Dry::Validation::Result) do |outcome|
            outcome.errors.each do |error|
              full_path = error.path.map { "[#{_1.to_s.inspect}]" }.join

              key.failure("Validation Error: #{full_path}: #{error.text}")
            end
          end

          m.failure do
            # simplecov:disable
            base.failure("Something went wrong when validating the schema.")
            # simplecov:enable
          end
        end
      end
    end
  end
end

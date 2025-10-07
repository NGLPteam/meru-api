# frozen_string_literal: true

module ControlledVocabularies
  module Static
    class SeedAll
      include Dry::Monads[:result, :list, :validated, :do]

      include MeruAPI::Deps[
        upsert: "controlled_vocabularies.upsert",
      ]

      STATIC_ROOT = Rails.root.join("lib", "controlled_vocabularies")

      def call
        static_definitions = STATIC_ROOT.glob("**/*.json")

        results = static_definitions.map { seed_static _1 }

        validations = yield List::Validated[*results].traverse.to_result

        yield set_default_provisions!

        Success validations
      end

      private

      # @param [Pathname] path
      # @return [Dry::Monads::Validated]
      def seed_static(path)
        definition = JSON.parse path.read
      rescue JSON::JSONError => e
        Invalid("#{path.relative_path_from(STATIC_ROOT)}: invalid JSON: #{e.message}")
      else
        upsert.(definition).to_validated
      end

      def set_default_provisions!
        yield set_default_provision!(identifier: "common_licenses", namespace: "meru.host")

        Success()
      end

      def set_default_provision!(identifier:, namespace: "meru.host")
        vocabulary = ControlledVocabulary.find_by(namespace:, identifier:)

        # :nocov:
        return Success() unless vocabulary.present?

        return Success() if ControlledVocabularySource.providing(vocabulary.provides).present?
        # :nocov:

        vocabulary.select_provider!

        Success()
      end
    end
  end
end

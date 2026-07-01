# frozen_string_literal: true

module Schemas
  module Versions
    # Perform a polymorphic lookup of a {SchemaVersion} with several strategies
    # based on the type of needle provided.
    class Find
      include Dry::Monads[:result]
      include Dry::Matcher.for(:call, with: Dry::Matcher::ResultMatcher)

      # @param [String, SchemaVersion, SchemaDefinition] needle
      # @return [Dry::Monads::Success(SchemaVersion)]
      # @return [Dry::Monads::Failure(:invalid, String)] When an invalid needle is provided.
      # @return [Dry::Monads::Failure(:no_versions, SchemaDefinition)]
      # @return [Dry::Monads::Failure(:not_found, String)] When an identifier or ID appears valid but has no matches in the system.
      # @return [Dry::Monads::Failure(:too_many_matches, String)] Edge case. Should not be seen.
      # @return [Dry::Monads::Failure(:unknown_signifier, String)] Edge case. Should not be seen.
      def call(needle)
        case needle
        when Schemas::Types::FLEXIBLE_DECLARATION_PATTERN
          parsed = Regexp.last_match.named_captures.symbolize_keys

          look_up_by_slug needle, **parsed
        when ::Support::GlobalTypes::UUID
          look_up_by_id needle
        when ::SchemaVersion
          Success needle
        when ::SchemaDefinition
          latest_version_for needle
        else
          Failure[:invalid, needle]
        end
      end

      private

      # @param [SchemaDefinition] definition
      # @return [Dry::Monads::Success(SchemaVersion)]
      # @return [Dry::Monads::Failure(:no_versions, SchemaDefinition)]
      def latest_version_for(definition)
        Success definition.schema_versions.latest!
      rescue ActiveRecord::RecordNotFound
        Failure[:no_versions, definition]
      end

      # @param [String] needle
      # @param [String] namespace
      # @param [String] identifier
      # @param [String] version
      # @return [Dry::Monads::Success(SchemaVersion)]
      # @return [Dry::Monads::Failure(:not_found, String)] When an identifier or ID appears valid but has no matches in the system.
      # @return [Dry::Monads::Failure(:too_many_matches, String)] Edge case. Should not be seen.
      # @return [Dry::Monads::Failure(:unknown_signifier, String)] Edge case. Should not be seen.
      def look_up_by_slug(needle, namespace:, identifier:, version: nil, **)
        scope = SchemaVersion.by_tuple namespace, identifier

        case version
        when nil, /\Alatest\z/i
          Success scope.latest!
        when Semantic::Version::SemVerRegexp
          Success scope.lookup version
        else
          # simplecov:disable
          Failure[:unknown_signifier, needle]
          # simplecov:enable
        end
      rescue LimitToOne::TooManyMatches
        # simplecov:disable
        Failure[:too_many_matches, needle]
        # simplecov:enable
      rescue ActiveRecord::RecordNotFound
        Failure[:not_found, needle]
      end

      # @param [String] id
      # @return [Dry::Monads::Success(SchemaVersion)]
      # @return [Dry::Monads::Failure(:no_versions, SchemaDefinition)]
      # @return [Dry::Monads::Failure(:not_found, String)]
      def look_up_by_id(id)
        try_model(SchemaVersion, id).or do
          try_model(SchemaDefinition, id).bind do |definition|
            latest_version_for definition
          end
        end
      end

      # @param [#find, Class] klass the {ApplicationRecord} model to search on
      # @param [String] id a primary key to search for
      # @return [Dry::Monads::Success(ApplicationRecord)]
      # @return [Dry::Monads::Failure(:not_found, String)]
      def try_model(klass, id)
        Success klass.find id
      rescue ActiveRecord::RecordNotFound
        Failure[:not_found, id]
      end
    end
  end
end

# frozen_string_literal: true

module Schemas
  module Versions
    # Reload the static configuration for a specific {SchemaVersion}.
    class Reload
      include Dry::Monads[:do, :result]
      include Schemas::Static::TracksLayoutDefinitions

      include MeruAPI::Deps[
        load_version: "schemas.static.load_version"
      ]

      # @param [SchemaVersion] schema_version
      # @note This does not return the same object in memory,
      #   as {Schemas::Static::LoadVersion} fetches a fresh
      #   {SchemaVersion}.
      # @return [Dry::Monads::Success(SchemaVersion)]
      def call(schema_version)
        # simplecov:disable
        return Failure[:not_builtin] unless schema_version.builtin?
        # simplecov:enable

        static_version = schema_version.static_record

        updated_version = capture_layout_definitions_to_invalidate! do
          yield load_version.call schema_version.schema_definition, static_version
        end

        schema_version.reload

        Success updated_version
      end
    end
  end
end

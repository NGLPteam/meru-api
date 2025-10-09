# frozen_string_literal: true

module Schemas
  module Static
    class LoadVersion
      include Dry::Monads[:do, :result]
      include Schemas::Static::SetsLayoutDefinitions

      include MeruAPI::Deps[
        validate_metaschema: "schemas.validate_metaschema",
      ]

      # @param [SchemaDefinition] definition
      # @param [StaticSchemaVersion] static_version
      # @return [SchemaVersion]
      def call(definition, static_version)
        configuration = yield validate static_version

        version = definition.lookup(static_version.number)

        version.configuration = configuration

        creating = version.new_record?

        # No validation errors should occur here during normal runtime.
        version.save!

        yield populate_root_layouts_for(version) unless creating

        Success version
      end

      private

      # @param [SchemaVersion] version
      # @return [Dry::Monads::Result]
      def populate_root_layouts_for(version)
        defs = yield version.populate_root_layouts(skip_layout_invalidation:)

        if LayoutsConfig.invalidate_on_deploy?
          layout_definitions.concat defs
        end

        Success()
      end

      # @param [Schemas::Static::Definitions::Version] static_version
      # @return [Dry::Monads::Result]
      def validate(static_version)
        static_version => { configuration: }

        validate_metaschema.call "entity-definition", configuration
      end
    end
  end
end

# frozen_string_literal: true

module Types
  module QueriesSchemas
    include Types::BaseInterface

    description <<~TEXT
    Fields for querying schemas and schema-related data.
    TEXT

    field :ordering_paths, [Types::OrderingPathType, { null: false }], null: false do
      description "A list of ordering paths for creating and updating orderings."

      argument :schemas, [Types::OrderingSchemaFilterInputType, { null: false }], required: false do
        description "If passed, this will restrict the property fields returned to the selected schemas."
      end
    end

    field :schema_definition, Types::SchemaDefinitionType, null: true do
      description "Look up a schema definition by slug"

      argument :slug, Types::SlugType, required: true
    end

    field :schema_definitions, resolver: Resolvers::SchemaDefinitionResolver do
      description "List all schema definitions"
    end

    field :schema_version, Types::SchemaVersionType, null: true do
      description "Look up a schema version by slug"

      argument :slug, Types::SlugType, required: true
    end

    field :schema_versions, resolver: Resolvers::SchemaVersionResolver do
      description "List all schema versions"
    end

    field :schema_version_options, resolver: Resolvers::SchemaVersionOptionResolver do
      description "List all options for schema versions"
    end

    # @see Schemas::Orderings::PathOptions::Fetch
    # @param [<Hash>] schemas (@see Schemas::Associations::OrderingFilter)
    # @return [<Schemas::Orderings::PathOptions::Reader>]
    def ordering_paths(schemas: [])
      call_operation! "schemas.orderings.path_options.fetch", schemas:
    end

    # @param [String] slug
    # @return [SchemaDefinition, nil]
    def schema_definition(slug:)
      MeruAPI::Container["schemas.definitions.find"].call(slug).value_or(nil)
    end

    # @param [String] slug
    # @return [SchemaVersion, nil]
    def schema_version(slug:)
      MeruAPI::Container["schemas.versions.find"].call(slug).value_or(nil)
    end
  end
end

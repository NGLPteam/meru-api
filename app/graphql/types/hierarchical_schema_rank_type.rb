# frozen_string_literal: true

module Types
  class HierarchicalSchemaRankType < Types::BaseObject
    implements GraphQL::Types::Relay::Node
    implements Types::DescribesSchemaType

    global_id_field :id

    description <<~TEXT
    A ranking of a schema from a certain point in the hierarchy. This can be used to generate
    navigation or calculate statistics about what various entities contain.
    TEXT

    field :count, Integer, null: false, method: :schema_count do
      description "The number of entities that implement this schema from this point in the hierarchy."
    end

    field :rank, Integer, null: false, method: :schema_rank do
      description "The rank of this schema at this point in the hierarchy, based on the statistical mode of its depth relative to the parent."
    end

    field :distinct_version_count, Integer, null: false do
      description "A count of distinct versions of this specific schema type from this point of the hierarchy."
    end

    field :schema_definition, Types::SchemaDefinitionType, null: false do
      description "A reference to the discrete schema definition"
    end

    field :slug, String, null: false, method: :schema_slug do
      description "A fully-qualified unique value that can be used to refer to this schema within the system"
    end

    field :version_ranks, [Types::HierarchicalSchemaVersionRankType, { null: false }], null: false do
      description "A reference to the schema versions from this ranking"
    end

    load_association! :schema_definition

    load_association! :hierarchical_schema_version_ranks, as: :version_ranks
  end
end

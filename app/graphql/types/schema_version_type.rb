# frozen_string_literal: true

module Types
  # @see SchemaVersion
  class SchemaVersionType < Types::AbstractModel
    description <<~TEXT
    A specific version of a `SchemaDefinition`.
    TEXT

    implements Types::DescribesSchemaType
    implements Types::SearchableType
    implements HasSchemaPropertiesType

    field :schema_definition, Types::SchemaDefinitionType, null: false do
      description <<~TEXT
      The shared schema definition for all versions of this namespace and identifier.
      TEXT
    end

    field :number, String, null: false do
      description <<~TEXT
      A semantic version for the schema
      TEXT
    end

    field :render, Types::SchemaRenderDefinitionType, null: false do
      description <<~TEXT
      Configuration for rendering schema instances outside of orderings.
      TEXT
    end

    field :searchable_properties, [Types::SearchablePropertyType, { null: false }], null: false do
      description <<~TEXT
      A subset of properties that can be searched for this schema.
      TEXT
    end

    field :enforced_parent_declarations, [Types::SlugType, { null: false }], null: false do
      description <<~TEXT
      Declarations / slugs for `enforcedParentVersions`.
      TEXT
    end

    field :enforced_parent_kinds, [::Types::SchemaKindType, { null: false }], null: false do
      description <<~TEXT
      A list of entity kinds that make acceptable parents for this schema.
      TEXT
    end

    field :enforced_parent_versions, [Types::SchemaVersionType, { null: false }], null: false do
      description <<~TEXT
      The versions that are allowed to parent this schema.

      If there are no schemas, then this schema does not enforce its parentage.
      TEXT
    end

    field :enforced_child_declarations, [Types::SlugType, { null: false }], null: false do
      description <<~TEXT
      Declarations / slugs for `enforcedChildVersions`.
      TEXT
    end

    field :enforced_child_kinds, [::Types::ChildEntityKindType, { null: false }], null: false do
      description <<~TEXT
      A list of entity kinds that make acceptable children for this schema.
      TEXT
    end

    field :enforced_child_versions, [Types::SchemaVersionType, { null: false }], null: false do
      description <<~TEXT
      The versions that this schema accepts as a child.

      If there are no schemas, then this schema does not enforce its children.
      TEXT
    end

    field :enforces_parent, Boolean, null: false do
      description "A boolean for the logic on `enforcedParentVersions`."
    end

    field :enforces_children, Boolean, null: false do
      description "A boolean for the logic on `enforcedChildVersions`."
    end

    load_association! :enforced_parent_versions

    load_association! :enforced_child_versions

    # @see Schemas::Versions::Configuration#render
    # @return [Schemas::Versions::RenderDefinition]
    def render
      object.configuration.render
    end

    def slug
      object.declaration
    end
  end
end

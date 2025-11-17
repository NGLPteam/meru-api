# frozen_string_literal: true

module Types
  # @see ChildEntity
  module ChildEntityType
    include Types::BaseInterface

    implements Types::EntityType
    implements Types::AccessibleType
    implements Types::ExposesPermissionsType
    implements Types::HasEntityBreadcrumbs
    implements Types::HasDefaultTimestamps
    implements Types::HasHarvestModificationStatusType
    implements Types::HasSchemaPropertiesType
    implements Types::HasDOIType
    implements Types::ReferencesEntityVisibilityType
    implements Types::ReferencesGlobalEntityDatesType
    implements Types::SearchableType

    description <<~TEXT
    An interface for entities that can contain actual content, as well as any number of themselves
    in a tree structure.

    In practice, this means a `Collection` or an `Item`, not a `Community`.
    TEXT

    field :community, Types::CommunityType, null: false do
      description "The community this entity belongs to"
    end

    field :identifier, String, null: false do
      description <<~TEXT.squish
      A machine-readable identifier for the entity. Not presently used, but will be necessary
      for synchronizing with upstream providers.
      TEXT
    end

    field :root, Boolean, null: false, method: :root?
    field :leaf, Boolean, null: false, method: :leaf?

    field :ancestor_by_name, Types::EntityType, null: true do
      description <<~TEXT
      Directly fetch a defined named ancestor by its name. It can be null,
      either because an invalid name was provided, the schema hierarchy is
      incomplete, or the association itself is optional.
      TEXT

      argument :name, String, required: true, description: "The name of the ancestor to fetch"
    end

    field :ancestor_of_type, Types::EntityType, null: true do
      description <<~TEXT
      Look up an ancestor for this entity that implements a specific type. It ascends from this entity,
      so it will first check the parent, then the grandparent, and so on.
      TEXT

      argument :schema, String, required: true, description: "A fully-qualified name of a schema to look for."
    end

    field :harvest_records, [::Types::HarvestRecordType, { null: false }], null: false do
      description <<~TEXT
      The harvest record(s) associated with the entity, with most recent harvest records sorted to the top.

      It is technically possible for multiple harvest records to have affected an entity.
      TEXT
    end

    field :named_ancestors, [Types::NamedAncestorType, { null: false }], null: false do
      description <<~TEXT
      Fetch a list of named ancestors for this entity. This list is deterministically sorted
      to retrieve the "closest" ancestors first, ascending upwards in the hierarchy from there.

      **Note**: Like breadcrumbs, this association is intentionally not paginated for ease of use,
      because in practice a schema should not have many associations.
      TEXT
    end

    load_association! :community
    load_association! :harvest_records
    load_association! :named_ancestors

    # @todo Perhaps error on receiving an unknown association?
    # @param [String] name
    # @return [HierarchicalEntity, nil]
    def ancestor_by_name(name:)
      object.ancestor_by_name(name)
    end

    # @param [String] schema
    # @return [HierarchicalEntity, nil]
    def ancestor_of_type(schema:)
      if MeruConfig.experimental_dataloader?
        dataloader.with(Sources::AncestorOfType, schema).load(object)
      else
        Loaders::AncestorOfTypeLoader.for(schema).load(object)
      end
    end
  end
end

# frozen_string_literal: true

module Types
  module EntityType
    include Types::BaseInterface

    implements ::Types::AccessibleType
    implements ::Types::EntityBaseType
    implements ::Types::EntityContextualPermissionsType
    implements ::Types::EntityPermissionsType
    implements ::Types::ExposesPermissionsType
    implements ::Types::HasEntityBreadcrumbs
    implements ::Types::HasSchemaPropertiesType
    implements ::Types::SearchableType
    implements ::Types::SluggableType

    description "An entity that exists in the hierarchy."

    field :announcement, Types::AnnouncementType, null: true do
      description "Look up an announcement for this entity by slug"

      argument :slug, SlugType, required: true
    end

    field :announcements, resolver: Resolvers::AnnouncementResolver do
      description <<~TEXT
      A list of announcements associated with this entity.
      TEXT
    end

    field :assigned_users, resolver: Resolvers::ContextualPermissionResolver do
      description "Retrieve a list of user & role assignments for this entity"
    end

    field :descendants, resolver: Resolvers::EntityDescendantResolver do
      description <<~TEXT
      All descendants of this entity, regardless of type.

      Communities and collections can both contain collections and items. Items will only contain items.
      TEXT
    end

    field :hierarchical_depth, Int, null: false do
      description <<~TEXT
      The depth of the hierarchical entity, taking into account any parent types.
      TEXT
    end

    field :layouts, ::Types::EntityLayoutsType, null: false do
      description <<~TEXT
      Access layouts for this entity.
      TEXT
    end

    field :links, resolver: Resolvers::EntityLinkResolver do
      description <<~TEXT
      Links from this entity to other entities, along with metadata about those links.
      TEXT
    end

    field :link_target_candidates, resolver: Resolvers::LinkTargetCandidateResolver do
      description <<~TEXT
      Available link targets for this entity.
      TEXT
    end

    field :marked_for_purge, Boolean, null: false do
      description <<~TEXT
      Purely informational at this point, this signifies an entity that is currently marked for purge by itself or a parent.
      TEXT
    end

    field :ordering, Types::OrderingType, null: true do
      description "Look up an ordering for this entity by identifier"

      argument :identifier, String, required: true
    end

    field :ordering_for_schema, Types::OrderingType, null: true do
      description "Look up an ordering that is set up to handle a specific schema."

      argument :slug, Types::SlugType, required: true do
        description "This should be of the `namespace:identifier` format."
      end
    end

    field :orderings, resolver: Resolvers::OrderingResolver do
      description <<~TEXT
      A list of orderings associated with this entity.
      TEXT
    end

    field :page, Types::PageType, null: true do
      description "Look up a page for this entity by slug"

      argument :slug, String, required: true do
        description <<~TEXT
        **Note**: Unlike most other model types, a page's slug is just a string
        as opposed to our custom `Slug` type. They are not designed to be
        opaque, but instead be something human-readable that can appear in URIs.
        TEXT
      end
    end

    field :pages, resolver: Resolvers::PageResolver do
      description <<~TEXT
      A list of pages associated with this entity.
      TEXT
    end

    field :schema_ranks, [Types::HierarchicalSchemaRankType, { null: false }], null: false do
      description <<~TEXT
      The hierarchical schema ranks for this entity, which compute the overall structure
      of its descendants by schema definition.
      TEXT
    end

    field :schema_definition, Types::SchemaDefinitionType, null: false do
      description <<~TEXT
      The schema definition that this entity conforms to.
      TEXT
    end

    field :schema_version, Types::SchemaVersionType, null: false do
      description <<~TEXT
      The schema version that this entity conforms to.
      TEXT
    end

    image_attachment_field :hero_image,
      description: "A hero image for the entity, suitable for displaying in page headers"

    image_attachment_field :thumbnail,
      description: "A representative thumbnail for the entity, suitable for displaying in lists, tables, grids, etc."

    load_association! :entity_links, as: :links

    load_association! :hierarchical_schema_ranks, as: :schema_ranks

    load_association! :schema_definition

    load_association! :schema_version

    # @see Entities::CheckLayouts
    # @see Entities::LayoutsChecker
    # @see Sources::EntityLayouts
    # @see Types::EntityLayoutsType
    # @return [Entities::LayoutsProxy, nil]
    def layouts
      if MeruConfig.experimental_dataloader?
        dataloader.with(Sources::EntityLayouts).load(object)
      else
        Loaders::EntityLayoutsLoader.load(object)
      end
    end

    # @param [String] identifier
    # @return [Ordering, nil]
    def ordering(identifier:)
      if MeruConfig.experimental_dataloader?
        dataloader.with(Sources::OrderingByIdentifier, identifier).load(object)
      else
        Loaders::OrderingByIdentifierLoader.for(identifier).load(object)
      end
    end

    # @param [String] slug
    # @return [Ordering, nil]
    def ordering_for_schema(slug:)
      if MeruConfig.experimental_dataloader?
        dataloader.with(Sources::OrderingBySchema, slug).load(object)
      else
        Loaders::OrderingBySchemaLoader.for(slug).load(object)
      end
    end

    # @param [String] slug
    # @return [Page, nil]
    def page(slug:)
      object.pages.by_slug(slug).first
    end

    # @param [String] slug
    # @return [Announcement, nil]
    def announcement(slug:)
      load_record_with(::Announcement, slug)
    end
  end
end

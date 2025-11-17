# frozen_string_literal: true

module Types
  module EntityType
    include Types::BaseInterface

    implements Types::AccessibleType
    implements Types::EntityBaseType
    implements Types::ExposesPermissionsType
    implements Types::HasEntityBreadcrumbs
    implements Types::HasSchemaPropertiesType
    implements Types::SearchableType
    implements ::Types::SluggableType

    description "An entity that exists in the hierarchy."

    field :access_control_list, Types::AccessControlListType, null: true do
      description "Derived access control list"
    end

    field :announcement, Types::AnnouncementType, null: true do
      description "Look up an announcement for this entity by slug"

      argument :slug, SlugType, required: true
    end

    field :announcements, resolver: Resolvers::AnnouncementResolver

    field :applicable_roles, [Types::RoleType, { null: false }], null: false do
      description "The role(s) that gave the permissions to access this resource, if any."
    end

    field :assignable_roles, [Types::RoleType, { null: false }], null: false do
      description "The role(s) that the current user could assign to other users on this entity, if applicable."
    end

    field :assigned_users, resolver: Resolvers::ContextualPermissionResolver do
      description "Retrieve a list of user & role assignments for this entity"
    end

    field :descendants, resolver: Resolvers::EntityDescendantResolver

    field :hierarchical_depth, Int, null: false do
      description "The depth of the hierarchical entity, taking into account any parent types"
    end

    field :layouts, ::Types::EntityLayoutsType, null: false do
      description <<~TEXT
      Access layouts for this entity.
      TEXT
    end

    field :links, resolver: Resolvers::EntityLinkResolver

    field :link_target_candidates, resolver: Resolvers::LinkTargetCandidateResolver,
      description: "Available link targets for this entity"

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

    field :orderings, resolver: Resolvers::OrderingResolver

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

    field :pages, resolver: Resolvers::PageResolver

    field :schema_ranks, [Types::HierarchicalSchemaRankType, { null: false }], null: false

    field :schema_definition, Types::SchemaDefinitionType, null: false

    field :schema_version, Types::SchemaVersionType, null: false

    image_attachment_field :hero_image,
      description: "A hero image for the entity, suitable for displaying in page headers"

    image_attachment_field :thumbnail,
      description: "A representative thumbnail for the entity, suitable for displaying in lists, tables, grids, etc."

    load_association! :entity_links, as: :links

    load_association! :hierarchical_schema_ranks, as: :schema_ranks

    # @!group Contextual Permission Support

    # @return [ContextualPermission]
    def contextual_permission
      if MeruConfig.experimental_dataloader?
        dataloader.with(Sources::ContextualPermission, context[:current_user]).load(object)
      else
        Loaders::ContextualPermissionLoader.for(context[:current_user]).load(object)
      end
    end

    # This surfaces the `access_control_list` from the associated {#contextual_permission}.
    #
    # @see ContextualPermission#access_control_list
    # @return [Roles::AccessControlList]
    def access_control_list
      contextual_permission.then do |permission|
        permission.access_control_list
      end
    end

    # This surfaces the `allowed_actions` from the associated {#contextual_permission}.
    #
    # @see ContextualPermission#allowed_actions
    # @return [String]
    def allowed_actions
      contextual_permission.then(&:allowed_actions)
    end

    # @return [Role]
    def assignable_roles
      contextual_permission.then(&:assignable_roles)
    end

    # @return [<Role>]
    def applicable_roles
      contextual_permission.then(&:roles)
    end

    # @return [<Permissions::Grant>]
    def permissions
      contextual_permission.then(&:permissions)
    end

    # @!endgroup

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

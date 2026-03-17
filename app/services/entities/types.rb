# frozen_string_literal: true

module Entities
  # Types related to managing and synchronizing an {Entity}.
  module Types
    extend ::Support::Typespace

    # A pattern for matching an auth_path, composed of multiple slugs
    AUTH_PATH_FORMAT = /\A[a-z0-9]+(?:(?:\.[a-z0-9]+)|(?<!\._)\._(?!\z))*\z/i

    DOI_DOMAIN = "doi.org"

    # @see https://www.crossref.org/blog/dois-and-matching-regular-expressions/
    DOI_PATTERN = %r|\A10\.\d{4,9}/[-._;()/:A-Z0-9]+\z|i

    DOI_SQL_PATTERN = %|^10\\.[0-9]{4,9}/[-._;()/:A-Z0-9]+$|

    DOI_URL_PATTERN = %r|\A(?:https?://)?#{DOI_DOMAIN}/(?<doi>10\.\d{4,9}/[-._;()/:A-Z0-9]+)\z|i

    HIERARCHICAL_TYPES = %w[Community Collection Item].freeze

    ENTITY_SCOPES = %w[communities collections items].freeze

    ENTITY_TYPES = [*HIERARCHICAL_TYPES, "EntityLink"].freeze

    SLUG_FORMAT = /\A[a-z0-9]+\z/i

    AuthPath = String.constrained(format: AUTH_PATH_FORMAT)

    ChildEntityKind = ApplicationRecord.dry_pg_enum(:child_entity_kind)

    DOI = String.constrained(format: DOI_PATTERN)

    DOI_URL = String.constrained(format: DOI_URL_PATTERN)

    Entity = Instance(::HierarchicalEntity)

    EntityScope = Coercible::String.enum(*ENTITY_SCOPES)

    EntityType = String.enum(*ENTITY_TYPES)

    Entities = Array.of(Entity)

    Generation = ::Rendering::Types::Generation

    HierarchicalType = String.enum(*HIERARCHICAL_TYPES)

    MaintenanceMode = Coercible::Symbol.default(:update).enum(:create, :update).fallback(:update)

    PurgeMode = Coercible::Symbol.default(:purge).enum(:purge, :mark).fallback(:purge)

    Scope = EntityScope | ::Links::Types::Scope

    Slug = String.constrained(format: SLUG_FORMAT)

    Syncable = Instance(::SyncsEntities)

    Syncables = Array.of(Syncable)

    URL = String.constrained(http_uri: true)

    Visibility = ApplicationRecord.dry_pg_enum(:entity_visibility)

    # @see ::Types::EntityVisibilityFilterType
    VisibilityFilter = Symbol.enum(:all, :visible, :hidden).fallback(:visible)

    # A type matching an ActiveRecord::Relation scope that {ReferencesEntityVisibility}.
    #
    # At minimum, it must respond to the mentioned scopes
    VisibilityRelation = Interface(:all, :currently_visible, :currently_hidden)
  end
end

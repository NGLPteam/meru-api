# frozen_string_literal: true

module Types
  # @see Permalink
  class PermalinkType < Types::AbstractModel
    description <<~TEXT
    A permalink is a persistant link to a resource with a human-readable URI.
    Each resource can have multiple permalinks, but only one can be marked as canonical.
    TEXT

    field :permalinkable, ::Types::PermalinkableType, null: false do
      description <<~TEXT
      The resource this permalink points to.
      TEXT
    end

    field :canonical, Boolean, null: false do
      description <<~TEXT
      Whether this permalink is the canonical one for the `permalinkable`.
      TEXT
    end

    field :uri, String, null: false do
      description <<~TEXT
      The URI of the permalink. Used for generating routes and also serves as a unique identifier.

      **Note**: URIs are _case-insensitive_ and may only contain alphanumeric characters and hyphens.
      Hyphens may not be consecutive nor may they appear at the start nor the end of the URI.
      TEXT
    end

    field :kind, Types::PermalinkableKindType, null: false do
      description <<~TEXT
      The type of resource this permalink points to.
      TEXT
    end

    field :permalinkable_slug, String, null: false do
      description <<~TEXT
      The slug of the `permalinkable` record.

      It can be used for quickly generating non-canonical links to the resource
      based on the `kind` without needing to load the associated record.
      TEXT
    end

    load_association! :permalinkable
  end
end

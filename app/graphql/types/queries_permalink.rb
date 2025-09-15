# frozen_string_literal: true

module Types
  # An interface for querying {Permalink}.
  module QueriesPermalink
    include Types::BaseInterface

    description <<~TEXT
    An interface for querying `Permalink` records.
    TEXT

    field :permalink, ::Types::PermalinkType, null: true do
      description <<~TEXT
      Retrieve a single `Permalink` by slug.
      TEXT

      argument :slug, Types::SlugType, required: true do
        description <<~TEXT
        The slug to look up.
        TEXT
      end
    end

    field :permalink_by_uri, ::Types::PermalinkType, null: true do
      description <<~TEXT
      Retrieve a single `Permalink` by its URI.
      TEXT

      argument :uri, String, required: true do
        description <<~TEXT
        The URI to look up.
        TEXT
      end
    end

    field :permalinks, resolver: ::Resolvers::PermalinkResolver

    # @param [String] slug
    # @return [Permalink, nil]
    def permalink(slug:)
      Support::Loaders::RecordLoader.for(Permalink).load(slug)
    end

    # @param [String] uri
    # @return [Permalink, nil]
    def permalink_by_uri(uri:)
      Support::Loaders::RecordLoader.for(Permalink, column: :uri).load(uri)
    end
  end
end

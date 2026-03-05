# frozen_string_literal: true

module Types
  # An interface for querying {DepositorRequest}.
  module QueriesDepositorRequest
    include Types::BaseInterface

    description <<~TEXT
    An interface for querying `DepositorRequest` records.
    TEXT

    field :depositor_request, ::Types::DepositorRequestType, null: true do
      description <<~TEXT
      Retrieve a single `DepositorRequest` by slug.
      TEXT

      argument :slug, Types::SlugType, required: true do
        description <<~TEXT
        The slug to look up.
        TEXT
      end
    end

    field :depositor_requests, resolver: ::Resolvers::DepositorRequestResolver

    # @param [String] slug
    # @return [DepositorRequest, nil]
    def depositor_request(slug:)
      load_record_with(DepositorRequest, slug)
    end
  end
end

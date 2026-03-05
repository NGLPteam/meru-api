# frozen_string_literal: true

module Resolvers
  # @see RelatedCollectionLink
  class RelatedCollectionResolver < AbstractResolver
    include Resolvers::Enhancements::PageBasedPagination
    include Resolvers::FiltersByEntityPermission
    include Resolvers::OrderedAsEntity

    applies_policy_scope!

    description "Retrieve linked collections of the same schema type"

    type "::Types::CollectionConnectionType", null: false

    graphql_name "CollectionConnection"

    resolves_model! ::Collection, association_name: :related_collections, must_have_object: true
  end
end

# frozen_string_literal: true

module Resolvers
  # A resolver for getting {Collection}s below a {Collection}.
  class SubcollectionResolver < AbstractResolver
    include Resolvers::Enhancements::PageBasedPagination
    include Resolvers::FiltersByEntityPermission
    include Resolvers::OrderedAsEntity
    include Resolvers::Subtreelike

    applies_policy_scope!

    description "Retrieve the collections beneath this collection."

    type "::Types::CollectionConnectionType", null: false

    graphql_name "CollectionConnection"

    resolves_model! ::Collection, must_have_object: true, association_name: :descendants

    def resolve_default_scope
      super.reorder(nil)
    end
  end
end

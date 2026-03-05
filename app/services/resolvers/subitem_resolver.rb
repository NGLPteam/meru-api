# frozen_string_literal: true

module Resolvers
  # A resolver for getting {Item}s below an {Item}.
  class SubitemResolver < AbstractResolver
    include Resolvers::Enhancements::PageBasedPagination
    include Resolvers::FiltersByEntityPermission
    include Resolvers::OrderedAsEntity
    include Resolvers::Subtreelike

    applies_policy_scope!

    description "Retrieve the items beneath this item"

    type "::Types::ItemConnectionType", null: false

    graphql_name "ItemConnection"

    resolves_model! ::Item, must_have_object: true, association_name: :descendants

    def resolve_default_scope
      super.reorder(nil)
    end
  end
end

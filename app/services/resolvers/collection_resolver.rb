# frozen_string_literal: true

module Resolvers
  class CollectionResolver < AbstractResolver
    include Resolvers::Enhancements::PageBasedPagination
    include Resolvers::FiltersByEntityPermission
    include Resolvers::OrderedAsEntity
    include Resolvers::Treelike

    applies_policy_scope!

    type ::Types::CollectionConnectionType, null: false

    resolves_model! ::Collection
  end
end

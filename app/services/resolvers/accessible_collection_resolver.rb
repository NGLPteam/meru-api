# frozen_string_literal: true

module Resolvers
  class AccessibleCollectionResolver < AbstractResolver
    include Resolvers::FiltersByEntityPermission
    include Resolvers::Enhancements::PageBasedPagination
    include Resolvers::OrderedAsEntity
    include Resolvers::Treelike

    type ::Types::CollectionConnectionType, null: false

    resolves_model! ::Collection, from_object: false
  end
end

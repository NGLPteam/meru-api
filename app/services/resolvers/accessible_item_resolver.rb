# frozen_string_literal: true

module Resolvers
  class AccessibleItemResolver < AbstractResolver
    include Resolvers::FiltersByEntityPermission
    include Resolvers::Enhancements::PageBasedPagination
    include Resolvers::OrderedAsEntity
    include Resolvers::Treelike

    type ::Types::ItemConnectionType, null: false

    resolves_model! ::Item, from_object: false
  end
end

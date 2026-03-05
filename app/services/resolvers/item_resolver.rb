# frozen_string_literal: true

module Resolvers
  # @see Item
  # @note We should not be fetching all items at once, but maybe we will in the future (for search?)
  class ItemResolver < AbstractResolver
    include Resolvers::Enhancements::PageBasedPagination
    include Resolvers::FiltersByEntityPermission
    include Resolvers::OrderedAsEntity
    include Resolvers::Treelike

    applies_policy_scope!

    type ::Types::ItemConnectionType, null: false

    resolves_model! ::Item, must_have_object: true
  end
end

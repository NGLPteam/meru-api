# frozen_string_literal: true

module Resolvers
  # @see RelatedItemLink
  class RelatedItemResolver < AbstractResolver
    include Resolvers::Enhancements::PageBasedPagination
    include Resolvers::FiltersByEntityPermission
    include Resolvers::OrderedAsEntity

    applies_policy_scope!

    description "Retrieve linked items of the same schema type"

    type "::Types::ItemConnectionType", null: false

    graphql_name "ItemConnection"

    resolves_model! ::Item, association_name: :related_items, must_have_object: true
  end
end

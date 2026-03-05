# frozen_string_literal: true

module Resolvers
  class CommunityResolver < AbstractResolver
    include Resolvers::Enhancements::PageBasedPagination
    include Resolvers::FiltersByEntityPermission
    include Resolvers::OrderedAsEntity

    applies_policy_scope!

    type ::Types::CommunityType.connection_type, null: false

    resolves_model! ::Community, from_object: false
  end
end

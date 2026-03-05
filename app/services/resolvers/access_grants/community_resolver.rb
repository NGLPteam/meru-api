# frozen_string_literal: true

module Resolvers
  module AccessGrants
    class CommunityResolver < AbstractResolver
      include AbstractAccessGrantResolver::ForCommunities
      include Resolvers::FiltersByAccessGrantSubject
      include Resolvers::Enhancements::PageBasedPagination
      include Resolvers::SimplyOrdered

      type ::Types::AnyCommunityAccessGrantType.connection_type, null: false
    end
  end
end

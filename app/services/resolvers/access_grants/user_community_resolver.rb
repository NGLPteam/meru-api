# frozen_string_literal: true

module Resolvers
  module AccessGrants
    class UserCommunityResolver < AbstractResolver
      include AbstractAccessGrantResolver::ForCommunities
      include AbstractAccessGrantResolver::ForUsers
      include Resolvers::Enhancements::PageBasedPagination
      include Resolvers::SimplyOrdered

      type ::Types::UserCommunityAccessGrantType.connection_type, null: false
    end
  end
end

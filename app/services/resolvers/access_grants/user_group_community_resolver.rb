# frozen_string_literal: true

module Resolvers
  module AccessGrants
    class UserGroupCommunityResolver < AbstractResolver
      include AbstractAccessGrantResolver::ForCommunities
      include AbstractAccessGrantResolver::ForGroups
      include Resolvers::Enhancements::PageBasedPagination
      include Resolvers::SimplyOrdered

      type ::Types::UserGroupCommunityAccessGrantType.connection_type, null: false
    end
  end
end

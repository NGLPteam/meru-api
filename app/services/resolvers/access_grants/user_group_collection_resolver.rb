# frozen_string_literal: true

module Resolvers
  module AccessGrants
    class UserGroupCollectionResolver < AbstractResolver
      include AbstractAccessGrantResolver::ForCollections
      include AbstractAccessGrantResolver::ForGroups
      include Resolvers::Enhancements::PageBasedPagination
      include Resolvers::SimplyOrdered

      type ::Types::UserGroupCollectionAccessGrantType.connection_type, null: false
    end
  end
end

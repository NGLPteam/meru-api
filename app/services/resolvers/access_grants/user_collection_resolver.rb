# frozen_string_literal: true

module Resolvers
  module AccessGrants
    class UserCollectionResolver < AbstractResolver
      include AbstractAccessGrantResolver::ForCollections
      include AbstractAccessGrantResolver::ForUsers
      include Resolvers::Enhancements::PageBasedPagination
      include Resolvers::SimplyOrdered

      type ::Types::UserCollectionAccessGrantType.connection_type, null: false
    end
  end
end

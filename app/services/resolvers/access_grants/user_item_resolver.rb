# frozen_string_literal: true

module Resolvers
  module AccessGrants
    class UserItemResolver < AbstractResolver
      include AbstractAccessGrantResolver::ForItems
      include AbstractAccessGrantResolver::ForUsers
      include Resolvers::Enhancements::PageBasedPagination
      include Resolvers::SimplyOrdered

      type ::Types::UserItemAccessGrantType.connection_type, null: false
    end
  end
end

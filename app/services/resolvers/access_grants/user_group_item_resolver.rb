# frozen_string_literal: true

module Resolvers
  module AccessGrants
    class UserGroupItemResolver < AbstractResolver
      include AbstractAccessGrantResolver::ForItems
      include AbstractAccessGrantResolver::ForGroups
      include Resolvers::Enhancements::PageBasedPagination
      include Resolvers::SimplyOrdered

      type ::Types::UserGroupItemAccessGrantType.connection_type, null: false
    end
  end
end

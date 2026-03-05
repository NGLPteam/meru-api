# frozen_string_literal: true

module Resolvers
  module AccessGrants
    class UserGroupResolver < AbstractResolver
      include AbstractAccessGrantResolver::ForGroups
      include Resolvers::FiltersByAccessGrantEntity
      include Resolvers::Enhancements::PageBasedPagination
      include Resolvers::SimplyOrdered

      type ::Types::AnyUserGroupAccessGrantType.connection_type, null: false
    end
  end
end

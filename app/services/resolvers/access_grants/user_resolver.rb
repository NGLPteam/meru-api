# frozen_string_literal: true

module Resolvers
  module AccessGrants
    class UserResolver < AbstractResolver
      include AbstractAccessGrantResolver::ForUsers
      include Resolvers::FiltersByAccessGrantEntity
      include Resolvers::Enhancements::PageBasedPagination
      include Resolvers::SimplyOrdered

      type ::Types::AnyUserAccessGrantType.connection_type, null: false
    end
  end
end

# frozen_string_literal: true

module Resolvers
  module AccessGrants
    class ItemResolver < AbstractResolver
      include AbstractAccessGrantResolver::ForItems
      include Resolvers::FiltersByAccessGrantSubject
      include Resolvers::Enhancements::PageBasedPagination
      include Resolvers::SimplyOrdered

      type ::Types::AnyItemAccessGrantType.connection_type, null: false
    end
  end
end

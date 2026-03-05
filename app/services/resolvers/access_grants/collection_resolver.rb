# frozen_string_literal: true

module Resolvers
  module AccessGrants
    class CollectionResolver < AbstractResolver
      include AbstractAccessGrantResolver::ForCollections
      include Resolvers::FiltersByAccessGrantSubject
      include Resolvers::Enhancements::PageBasedPagination
      include Resolvers::SimplyOrdered

      type ::Types::AnyCollectionAccessGrantType.connection_type, null: false
    end
  end
end

# frozen_string_literal: true

module Resolvers
  module AccessGrants
    # A resolver for {Types::AccessibleType}.
    class AccessibleResolver < AbstractResolver
      include AbstractAccessGrantResolver
      include Resolvers::FiltersByAccessGrantSubject
      include Resolvers::Enhancements::PageBasedPagination
      include Resolvers::SimplyOrdered

      type ::Types::AnyAccessGrantType.connection_type, null: false
    end
  end
end

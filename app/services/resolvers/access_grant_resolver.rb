# frozen_string_literal: true

module Resolvers
  class AccessGrantResolver < AbstractResolver
    include Resolvers::FiltersByAccessGrantEntity
    include Resolvers::FiltersByAccessGrantSubject
    include Resolvers::Enhancements::PageBasedPagination
    include Resolvers::SimplyOrdered

    applies_policy_scope!

    type ::Types::AnyAccessGrantType.connection_type, null: false

    resolves_model! ::AccessGrant

    def resolve_default_scope
      super.with_preloads
    end
  end
end

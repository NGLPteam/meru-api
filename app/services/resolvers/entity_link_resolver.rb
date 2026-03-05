# frozen_string_literal: true

module Resolvers
  class EntityLinkResolver < AbstractResolver
    include Resolvers::Enhancements::PageBasedPagination
    include Resolvers::SimplyOrdered

    type ::Types::EntityLinkType.connection_type, null: false

    resolves_model! ::EntityLink, must_have_object: true
  end
end

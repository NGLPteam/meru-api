# frozen_string_literal: true

module Resolvers
  # Orders {Role} models.
  class RoleResolver < AbstractResolver
    include Resolvers::OrderedAsRole

    type ::Types::RoleType.connection_type, null: false

    resolves_model! ::Role
  end
end

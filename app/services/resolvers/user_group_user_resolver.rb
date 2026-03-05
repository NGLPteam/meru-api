# frozen_string_literal: true

module Resolvers
  class UserGroupUserResolver < AbstractResolver
    include Resolvers::Enhancements::PageBasedPagination
    include Resolvers::OrderedAsUser

    applies_policy_scope!

    type ::Types::UserType.connection_type, null: false

    resolves_model! ::User, must_have_object: true
  end
end

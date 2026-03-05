# frozen_string_literal: true

module Resolvers
  class UserResolver < AbstractResolver
    include Resolvers::Enhancements::PageBasedPagination
    include Resolvers::OrderedAsUser

    applies_policy_scope!

    type ::Types::UserType.connection_type, null: false

    option :prefix, type: String, description: option_description_for(:prefix) do |scope, value|
      scope.apply_prefix value
    end

    resolves_model! ::User
  end
end

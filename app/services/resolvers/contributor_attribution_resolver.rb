# frozen_string_literal: true

module Resolvers
  # A resolver for a {ContributorAttribution}.
  #
  # @see ContributorAttribution
  # @see ::Types::ContributorAttributionType
  class ContributorAttributionResolver < AbstractResolver
    include Resolvers::Enhancements::PageBasedPagination
    include Resolvers::OrderedAsContributorAttribution

    applies_policy_scope!

    type ::Types::ContributorAttributionType.connection_type, null: false

    resolves_model! ::ContributorAttribution, must_have_object: true
  end
end

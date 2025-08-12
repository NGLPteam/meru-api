# frozen_string_literal: true

module Resolvers
  # A resolver for a {ContributorAttribution}.
  #
  # @see ContributorAttribution
  # @see Types::ContributorAttributionType
  class ContributorAttributionResolver < AbstractResolver
    include Resolvers::Enhancements::AppliesPolicyScope
    include Resolvers::Enhancements::PageBasedPagination
    include Resolvers::OrderedAsContributorAttribution

    type Types::ContributorAttributionType.connection_type, null: false

    scope do
      case object
      when ::Contributor
        object.contributor_attributions
      else
        # :nocov:
        ContributorAttribution.none
        # :nocov:
      end
    end
  end
end

# frozen_string_literal: true

module Resolvers
  # A resolver for a {HarvestAttempt}.
  #
  # @see HarvestAttempt
  # @see ::Types::HarvestAttemptType
  class HarvestAttemptResolver < AbstractResolver
    include Resolvers::Enhancements::PageBasedPagination
    include Resolvers::OrderedAsHarvestAttempt

    applies_policy_scope!

    type ::Types::HarvestAttemptType.connection_type, null: false

    resolves_model! ::HarvestAttempt
  end
end

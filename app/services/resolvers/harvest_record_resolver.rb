# frozen_string_literal: true

module Resolvers
  # A resolver for a {HarvestRecord}.
  #
  # @see HarvestRecord
  # @see ::Types::HarvestRecordType
  class HarvestRecordResolver < AbstractResolver
    include Resolvers::Enhancements::PageBasedPagination
    include Resolvers::OrderedAsHarvestRecord

    applies_policy_scope!

    type ::Types::HarvestRecordType.connection_type, null: false

    resolves_model! ::HarvestRecord
  end
end

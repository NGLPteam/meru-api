# frozen_string_literal: true

module Resolvers
  class ItemContributionResolver < AbstractResolver
    include Resolvers::OrderedAsContribution
    include Resolvers::Enhancements::PageBasedPagination

    type ::Types::ItemContributionType.connection_type, null: false

    resolves_model! ::ItemContribution, must_have_object: true

    def default_object_association_name
      if object.kind_of?(Contributor)
        :item_contributions
      else
        super
      end
    end
  end
end

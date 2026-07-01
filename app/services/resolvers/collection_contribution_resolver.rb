# frozen_string_literal: true

module Resolvers
  class CollectionContributionResolver < AbstractResolver
    include Resolvers::OrderedAsContribution
    include Resolvers::Enhancements::PageBasedPagination

    type ::Types::CollectionContributionType.connection_type, null: false

    resolves_model! ::CollectionContribution, must_have_object: true

    def default_object_association_name
      if object.kind_of?(Contributor)
        :collection_contributions
      elsif object.kind_of?(Collection)
        :contributions
      else
        # simplecov:disable
        super
        # simplecov:enable
      end
    end
  end
end

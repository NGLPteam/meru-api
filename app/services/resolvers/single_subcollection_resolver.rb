# frozen_string_literal: true

module Resolvers
  # A resolver for getting the first-matching {Collection} below a {Collection}.
  class SingleSubcollectionResolver < AbstractResolver
    include Resolvers::Enhancements::FirstMatching
    include Resolvers::OrderedAsEntity
    include Resolvers::Subtreelike

    applies_policy_scope!

    description "Retrieve the first matching collection beneath this collection."

    type "::Types::CollectionType", null: true

    resolves_model! ::Collection, must_have_object: true

    graphql_name "Collection"

    def default_object_association_name
      if kind_of?(Collection)
        :descendants
      else
        super
      end
    end

    def resolve_default_scope
      super.reorder(nil)
    end
  end
end

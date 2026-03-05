# frozen_string_literal: true

module Resolvers
  # A resolver for getting the first-matching {Item} below a {Item}.
  class SingleSubitemResolver < AbstractResolver
    include Resolvers::Enhancements::FirstMatching
    include Resolvers::OrderedAsEntity
    include Resolvers::Subtreelike

    applies_policy_scope!

    description "Retrieve the first matching item beneath this item."

    type "::Types::ItemType", null: true

    resolves_model! ::Item, must_have_object: true

    graphql_name "Item"

    def default_object_association_name
      if kind_of?(Item)
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

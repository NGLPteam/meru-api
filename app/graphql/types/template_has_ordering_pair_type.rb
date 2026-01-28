# frozen_string_literal: true

module Types
  module TemplateHasOrderingPairType
    include Types::BaseInterface

    description <<~TEXT
    An interface that implements the `prev` / `next` siblings
    for navigating through orderings.
    TEXT

    field :ordering_pair, Types::TemplateOrderingPairType, null: false do
      description <<~TEXT
      Access the prev/next siblings within the template's specified ordering.
      TEXT
    end

    load_association! :ordering
    load_association! :prev_sibling
    load_association! :next_sibling

    # @return [Templates::OrderingPair]
    def ordering_pair
      assocs = [ordering, prev_sibling, next_sibling]

      maybe_await(assocs).then do
        object.ordering_pair
      end
    end
  end
end

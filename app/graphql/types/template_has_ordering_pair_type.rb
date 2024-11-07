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
    load_association! :ordering_entry_count
    load_association! :prev_sibling
    load_association! :next_sibling

    # @return [Promise(Templates::OrderingPair)]
    def ordering_pair
      assocs = [ordering, ordering_entry_count, prev_sibling, next_sibling]

      Promise.all(assocs).then do
        object.ordering_pair
      end
    end
  end
end

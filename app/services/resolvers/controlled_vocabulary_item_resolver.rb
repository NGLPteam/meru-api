# frozen_string_literal: true

module Resolvers
  # A resolver for a {ControlledVocabularyItem}.
  #
  # @see ControlledVocabularyItem
  # @see ::Types::ControlledVocabularyItemType
  class ControlledVocabularyItemResolver < AbstractResolver
    include Resolvers::Enhancements::PageBasedPagination
    include Resolvers::OrderedAsControlledVocabularyItem

    applies_policy_scope!

    type ::Types::ControlledVocabularyItemType.connection_type, null: false

    resolves_model! ::ControlledVocabularyItem
  end
end

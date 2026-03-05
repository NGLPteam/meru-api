# frozen_string_literal: true

module Resolvers
  # A resolver for a {ControlledVocabularySource}.
  #
  # @see ControlledVocabularySource
  # @see ::Types::ControlledVocabularySourceType
  class ControlledVocabularySourceResolver < AbstractResolver
    include Resolvers::Enhancements::PageBasedPagination
    include Resolvers::OrderedAsControlledVocabularySource

    applies_policy_scope!

    type ::Types::ControlledVocabularySourceType.connection_type, null: false

    resolves_model! ::ControlledVocabularySource, from_object: false

    filters_with! Filtering::Scopes::ControlledVocabularySources
  end
end

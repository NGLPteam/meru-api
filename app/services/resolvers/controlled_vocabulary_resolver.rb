# frozen_string_literal: true

module Resolvers
  # A resolver for a {ControlledVocabulary}.
  #
  # @see ControlledVocabulary
  # @see ::Types::ControlledVocabularyType
  class ControlledVocabularyResolver < AbstractResolver
    include Resolvers::Enhancements::PageBasedPagination
    include Resolvers::OrderedAsControlledVocabulary

    applies_policy_scope!

    type ::Types::ControlledVocabularyType.connection_type, null: false

    resolves_model! ::ControlledVocabulary, from_object: false

    filters_with! ::Filtering::Scopes::ControlledVocabularies
  end
end

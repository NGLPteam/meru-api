# frozen_string_literal: true

module Types
  module Filtering
    # @see ::Filtering::Scopes::ControlledVocabularySources
    class ControlledVocabularySourceFilterInputType < ::Support::GQL::BaseFilterScopeInputObject
      description <<~TEXT
      Filtering options for `ControlledVocabularySource` records.
      TEXT

      inherit_from!(::Filtering::Scopes::ControlledVocabularySources)

      argument :unsatisfied, ::GraphQL::Types::Boolean, required: false do
        description <<~TEXT
        Fetch only sources that remain unsatisfied.
        TEXT
      end
    end
  end
end

# frozen_string_literal: true

module Types
  module Filtering
    # @see ::Filtering::Scopes::ControlledVocabularies
    class ControlledVocabularyFilterInputType < ::Support::GQL::BaseFilterScopeInputObject
      description <<~TEXT
      Filtering options for `ControlledVocabulary` records.
      TEXT

      inherit_from!(::Filtering::Scopes::ControlledVocabularies)

      argument :namespace, ::GraphQL::Types::String, required: false do
        description <<~TEXT
        Filter by namespace.
        TEXT
      end

      argument :identifier, ::GraphQL::Types::String, required: false do
        description <<~TEXT
        Filter by identifier.
        TEXT
      end

      argument :provides, ::GraphQL::Types::String, required: false do
        description <<~TEXT
        Filter by provides.
        TEXT
      end
    end
  end
end

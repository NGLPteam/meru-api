# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    description <<~TEXT
    The entry point for retrieving data from within the Meru API.
    TEXT

    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    implements Types::QueriesAccessAndRoles
    implements Types::QueriesContrib
    implements Types::QueriesControlledVocabulary
    implements Types::QueriesControlledVocabularySource
    implements Types::QueriesEntities
    implements Types::QueriesHarvestAttempt
    implements Types::QueriesHarvestExample
    implements Types::QueriesHarvestMapping
    implements Types::QueriesHarvestMessage
    implements Types::QueriesHarvestRecord
    implements Types::QueriesHarvestSet
    implements Types::QueriesHarvestSource
    implements Types::QueriesPermalink
    implements Types::QueriesSchemas
    implements Types::QueriesSystem
    implements Types::QueriesUser
    implements Types::SearchableType

    def search_origin
      :global
    end
  end
end

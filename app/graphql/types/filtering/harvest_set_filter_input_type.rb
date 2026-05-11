# frozen_string_literal: true

module Types
  module Filtering
    # @see ::Filtering::Scopes::HarvestSets
    class HarvestSetFilterInputType < ::Support::GQL::BaseFilterScopeInputObject
      description <<~TEXT
      Filtering options for `HarvestSet` records.
      TEXT

      inherit_from!(::Filtering::Scopes::HarvestSets)

      argument :identifier, ::GraphQL::Types::String, required: false do
        description <<~TEXT
        Filter by identifier.
        TEXT
      end

      argument :name, ::GraphQL::Types::String, required: false do
        description <<~TEXT
        Filter by name.
        TEXT
      end

      argument :prefix, ::GraphQL::Types::String, required: false do
        description <<~TEXT
        Filter by prefix.
        TEXT
      end
    end
  end
end

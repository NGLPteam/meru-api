# frozen_string_literal: true

module Types
  module Filtering
    # @see ::Filtering::Scopes::Contributors
    class ContributorFilterInputType < ::Support::GQL::BaseFilterScopeInputObject
      description <<~TEXT
      Filtering options for `Contributor` records.
      TEXT

      inherit_from!(::Filtering::Scopes::Contributors)

      argument :name_search, ::Support::GQL::FullTextSearchQueryInputType, required: false do
        description <<~TEXT
        Perform a full-text search with the provided query.
        TEXT
      end

      argument :unclaimed, ::GraphQL::Types::Boolean, required: false do
        description <<~TEXT
        Whether to include only contributors that have not been claimed by a user.
        TEXT
      end

      argument :created_at, ::Support::GQL::FilterMatchTimeInputType, required: false do
        description <<~TEXT
        Filter the model's `created_at` with time constraints.
        TEXT
      end

      argument :updated_at, ::Support::GQL::FilterMatchTimeInputType, required: false do
        description <<~TEXT
        Filter the model's `updated_at` with time constraints.
        TEXT
      end
    end
  end
end

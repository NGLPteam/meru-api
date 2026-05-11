# frozen_string_literal: true

module Types
  module Filtering
    # @see ::Filtering::Scopes::Items
    class ItemFilterInputType < ::Support::GQL::BaseFilterScopeInputObject
      description <<~TEXT
      Filtering options for `Item` records.
      TEXT

      inherit_from!(::Filtering::Scopes::Items)

      argument :include_drafts, ::GraphQL::Types::Boolean, required: false, default_value: false, replace_null_with_default: true do
        description <<~TEXT
        Whether to include items that are in draft state (i.e. items that are associated with a submission).
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

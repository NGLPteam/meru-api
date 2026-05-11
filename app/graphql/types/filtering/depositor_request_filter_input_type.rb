# frozen_string_literal: true

module Types
  module Filtering
    # @see ::Filtering::Scopes::DepositorRequests
    class DepositorRequestFilterInputType < ::Support::GQL::BaseFilterScopeInputObject
      description <<~TEXT
      Filtering options for `DepositorRequest` records.
      TEXT

      inherit_from!(::Filtering::Scopes::DepositorRequests)

      argument :in_state, [::Types::DepositorRequestStateType, { null: false }], required: false do
        description <<~TEXT
        Filter by in state.
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

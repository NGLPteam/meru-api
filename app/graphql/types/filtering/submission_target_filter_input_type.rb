# frozen_string_literal: true

module Types
  module Filtering
    # @see ::Filtering::Scopes::SubmissionTargets
    class SubmissionTargetFilterInputType < ::Support::GQL::BaseFilterScopeInputObject
      description <<~TEXT
      Filtering options for `SubmissionTarget` records.
      TEXT

      inherit_from!(::Filtering::Scopes::SubmissionTargets)

      argument :in_state, [::Types::SubmissionTargetStateType, { null: false }], required: false do
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

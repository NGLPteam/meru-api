# frozen_string_literal: true

module Types
  module Filtering
    # @see ::Filtering::Scopes::SubmissionComments
    class SubmissionCommentFilterInputType < ::Support::GQL::BaseFilterScopeInputObject
      description <<~TEXT
      Filtering options for `SubmissionComment` records.
      TEXT

      inherit_from!(::Filtering::Scopes::SubmissionComments)

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

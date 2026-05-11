# frozen_string_literal: true

module Types
  module Filtering
    # @see ::Filtering::Scopes::SubmissionReviews
    class SubmissionReviewFilterInputType < ::Support::GQL::BaseFilterScopeInputObject
      description <<~TEXT
      Filtering options for `SubmissionReview` records.
      TEXT

      inherit_from!(::Filtering::Scopes::SubmissionReviews)

      argument :in_state, [::Types::SubmissionReviewStateType, { null: false }], required: false do
        description <<~TEXT
        Filter by in state.
        TEXT
      end

      argument :submission_ids, [::GraphQL::Types::ID, { null: false }], loads: ::Types::SubmissionType, as: :submission, required: false do
        description <<~TEXT
        Filter by multiple Submission.
        TEXT
      end

      argument :user_ids, [::GraphQL::Types::ID, { null: false }], loads: ::Types::UserType, as: :user, required: false do
        description <<~TEXT
        Filter by multiple User.
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

# frozen_string_literal: true

module Types
  module Filtering
    # @see ::Filtering::Scopes::SubmissionTargetReviewers
    class SubmissionTargetReviewerFilterInputType < ::Support::GQL::BaseFilterScopeInputObject
      description <<~TEXT
      Filtering options for `SubmissionTargetReviewer` records.
      TEXT

      inherit_from!(::Filtering::Scopes::SubmissionTargetReviewers)

      argument :submission_target_ids, [::GraphQL::Types::ID, { null: false }], loads: ::Types::SubmissionTargetType, as: :submission_target, required: false do
        description <<~TEXT
        Filter by the submission target.
        TEXT
      end

      argument :user_ids, [::GraphQL::Types::ID, { null: false }], loads: ::Types::UserType, as: :user, required: false do
        description <<~TEXT
        Filter by the associated user.
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

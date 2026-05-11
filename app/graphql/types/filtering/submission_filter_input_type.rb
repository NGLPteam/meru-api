# frozen_string_literal: true

module Types
  module Filtering
    # @see ::Filtering::Scopes::Submissions
    class SubmissionFilterInputType < ::Support::GQL::BaseFilterScopeInputObject
      description <<~TEXT
      Filtering options for `Submission` records.
      TEXT

      inherit_from!(::Filtering::Scopes::Submissions)

      argument :prefix, ::GraphQL::Types::String, required: false do
        description <<~TEXT
        Perform a full-text search to approximately match the provided string.
        TEXT
      end

      argument :query, ::GraphQL::Types::String, required: false do
        description <<~TEXT
        Perform a full-text search to approximately match the provided string.
        TEXT
      end

      argument :parent_entity_ids, [::GraphQL::Types::ID, { null: false }], loads: ::Types::EntityType, as: :parent_entity, required: false do
        description <<~TEXT
        Filter submissions to only those with the given parent entity(ies).
        TEXT
      end

      argument :schema_version_ids, [::GraphQL::Types::ID, { null: false }], loads: ::Types::SchemaVersionType, as: :schema_version, required: false do
        description <<~TEXT
        Filter submissions to only those with the given schema version(s).
        TEXT
      end

      argument :in_state, [::Types::SubmissionStateType, { null: false }], required: false do
        description <<~TEXT
        Filter by in state.
        TEXT
      end

      argument :submission_target_ids, [::GraphQL::Types::ID, { null: false }], loads: ::Types::SubmissionTargetType, as: :submission_target, required: false do
        description <<~TEXT
        Filter submissions to only those with the given submission target(s).
        TEXT
      end

      argument :user_ids, [::GraphQL::Types::ID, { null: false }], loads: ::Types::UserType, as: :user, required: false do
        description <<~TEXT
        Filter submissions to only those created by the given user(s).
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

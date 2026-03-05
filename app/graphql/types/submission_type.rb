# frozen_string_literal: true

module Types
  # @see Submission
  # @see ::Types::SubmissionConnectionType
  # @see ::Types::SubmissionEdgeType
  class SubmissionType < Types::AbstractModel
    description <<~TEXT
    A submission against a `SubmissionTarget`, representing a single attempt
    to deposit an entity into the system.
    TEXT

    use_direct_connection_and_edge!

    field :entity, "::Types::EntityType", null: true do
      description <<~TEXT
      The actual entity record that will be published as part of this submission.

      The actual edits and content for the entity happen on it.
      TEXT
    end

    field :user, "::Types::UserType", null: false do
      description <<~TEXT
      The user that created this submission.
      TEXT
    end

    field :transitions, resolver: ::Resolvers::SubmissionTransitionResolver, null: false do
      description <<~TEXT
      The state transitions that this submission has undergone.
      TEXT
    end

    expose_authorization_rule :alter_schema_version?, <<~TEXT
    Whether or not the current user can alter the schema version of this submission.
    TEXT

    expose_authorization_rule :comment?, <<~TEXT
    Whether or not the current user can comment on this submission.
    TEXT

    expose_authorization_rule :migrate?, <<~TEXT
    Whether or not the current user can migrate this submission.
    TEXT

    expose_authorization_rule :request_review?, <<~TEXT
    Whether or not the current user can request a review of this submission.
    TEXT

    expose_authorization_rule :review?, <<~TEXT
    Whether or not the current user can review this submission.
    TEXT
  end
end

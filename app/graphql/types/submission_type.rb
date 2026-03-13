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

    field :state, Types::SubmissionStateType, null: false do
      description <<~TEXT
      The current state of the submission.
      TEXT
    end

    field :entity, "::Types::EntityType", null: true do
      description <<~TEXT
      The actual entity record that will be published as part of this submission.

      The actual edits and content for the entity happen on it.
      TEXT
    end

    field :submission_target, "::Types::SubmissionTargetType", null: true do
      description <<~TEXT
      The {SubmissionTarget} against which this submission is being made.

      It can be null if the submission gets moved away later after publication.
      TEXT
    end

    field :user, "::Types::UserType", null: false do
      description <<~TEXT
      The user that created this submission.
      TEXT
    end

    field :available_transitions, [::Types::SubmissionStatusType], null: false do
      description <<~TEXT
      The state transitions that are available for this submission,
      based on its current state and the permissions of the current user.
      TEXT
    end

    field :current_status, Types::SubmissionStatusType, null: false do
      description <<~TEXT
      The current status of the submission, similar to `state` but with metadata about mutability and locking.
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

    expose_authorization_rule :publish?, <<~TEXT
    Whether or not the current user can publish this submission.
    TEXT

    expose_authorization_rule :request_review?, <<~TEXT
    Whether or not the current user can request a review of this submission.
    TEXT

    expose_authorization_rule :review?, <<~TEXT
    Whether or not the current user can review this submission.
    TEXT

    load_association! :entity

    load_association! :submission_target

    load_association! :user
  end
end

# frozen_string_literal: true

module Types
  # @see DepositorAgreement
  # @see ::Types::DepositorAgreementConnectionType
  # @see ::Types::DepositorAgreementEdgeType
  class DepositorAgreementType < Types::AbstractModel
    description <<~TEXT
    The record of an agreement accepted by a depositor for a given submission target.
    TEXT

    use_direct_connection_and_edge!

    field :state, Types::DepositorAgreementStateType, null: false do
      description <<~TEXT
      The current state of the agreement.
      TEXT
    end

    field :submission_target, "Types::SubmissionTargetType", null: false do
      description <<~TEXT
      The submission target associated with this agreement.
      TEXT
    end

    field :user, "Types::UserType", null: true do
      description <<~TEXT
      The user who accepted the agreement.
      TEXT
    end

    field :last_accepted_at, GraphQL::Types::ISO8601DateTime, null: true do
      description <<~TEXT
      The timestamp of the most recent time the agreement was accepted by the depositor.
      TEXT
    end

    field :transitions, resolver: Resolvers::DepositorAgreementTransitionResolver, null: false do
      description <<~TEXT
      The state transitions for this agreement.
      TEXT
    end

    expose_authorization_rule :accept?, <<~TEXT
    Whether the current user can accept this agreement.
    TEXT

    expose_authorization_rule :reset?, <<~TEXT
    Whether the current user can reset this agreement.
    TEXT

    load_association! :submission_target

    load_association! :user
  end
end

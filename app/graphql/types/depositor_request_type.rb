# frozen_string_literal: true

module Types
  # @see DepositorRequest
  # @see ::Types::DepositorRequestConnectionType
  # @see ::Types::DepositorRequestEdgeType
  class DepositorRequestType < Types::AbstractModel
    description <<~TEXT
    A request for depositor access to a given submission target.
    TEXT

    use_direct_connection_and_edge!

    field :state, Types::DepositorRequestStateType, null: false do
      description <<~TEXT
      The current state of this depositor request.
      TEXT
    end

    field :submission_target, "::Types::SubmissionTargetType", null: false do
      description <<~TEXT
      The submission target that this depositor request is for.
      TEXT
    end

    field :user, "::Types::UserType", null: false do
      description <<~TEXT
      The user that made this depositor request.
      TEXT
    end

    field :message, String, null: true do
      description <<~TEXT
      An optional message from the requester, which may be provided when making the depositor request and may be visible to management.
      TEXT
    end

    expose_authorization_rule :transition?, <<~TEXT
    Whether the current user can approve or reject the request.
    TEXT

    load_association! :submission_target

    load_association! :user
  end
end

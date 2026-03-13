# frozen_string_literal: true

module Types
  # @see SubmissionPublication
  # @see ::Types::SubmissionPublicationConnectionType
  # @see ::Types::SubmissionPublicationEdgeType
  class SubmissionPublicationType < Types::AbstractModel
    description <<~TEXT
    The record of a `Submission`'s publication process.
    TEXT

    use_direct_connection_and_edge!

    field :state, Types::SubmissionPublicationStateType, null: false do
      description <<~TEXT
      The state of the publication process.
      TEXT
    end

    field :submission, "Types::SubmissionType", null: false do
      description <<~TEXT
      The submission that is being published.
      TEXT
    end

    field :user, "Types::UserType", null: true do
      description <<~TEXT
      The user that initiated the publication process, if applicable.
      TEXT
    end

    field :transitions, resolver: Resolvers::SubmissionPublicationTransitionResolver, null: false do
      description <<~TEXT
      The transitions that the publication process has gone through.
      TEXT
    end

    load_association! :submission

    load_association! :user
  end
end

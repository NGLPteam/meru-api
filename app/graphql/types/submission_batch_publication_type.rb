# frozen_string_literal: true

module Types
  # @see SubmissionBatchPublication
  # @see ::Types::SubmissionBatchPublicationConnectionType
  # @see ::Types::SubmissionBatchPublicationEdgeType
  class SubmissionBatchPublicationType < Types::AbstractModel
    description <<~TEXT
    The record of a batch publication of one or more submissions within a submission target.
    TEXT

    use_direct_connection_and_edge!

    field :state, Types::SubmissionBatchPublicationStateType, null: false do
      description <<~TEXT
      The current state of the batch publication process.
      TEXT
    end

    field :submission_target, Types::SubmissionTargetType, null: false do
      description <<~TEXT
      The submission target that the included submissions belong to.
      TEXT
    end

    field :user, Types::UserType, null: true do
      description <<~TEXT
      The user that initiated the batch publication, if applicable.
      TEXT
    end

    field :publications, [Types::SubmissionPublicationType, { null: false }], null: false do
      description <<~TEXT
      The list of submissions included in this batch publication.
      TEXT
    end

    field :publications_count, Integer, null: false do
      description <<~TEXT
      The total number of submissions included in this batch publication.
      TEXT
    end

    field :transitions, resolver: Resolvers::SubmissionBatchPublicationTransitionResolver, null: false do
      description <<~TEXT
      The transitions that the batch publication process has gone through.
      TEXT
    end

    load_association! :submission_target

    load_association! :user

    load_association! :submission_publications, as: :publications
  end
end

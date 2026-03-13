# frozen_string_literal: true

module Types
  # A connection type for {SubmissionBatchPublication}-typed records.
  #
  # @see SubmissionBatchPublication
  # @see ::Types::SubmissionBatchPublicationEdgeType
  # @see ::Types::SubmissionBatchPublicationType
  class SubmissionBatchPublicationConnectionType < Types::BaseConnection
    graphql_name "SubmissionBatchPublicationConnection"

    description <<~TEXT
    A connection type for `SubmissionBatchPublication`.
    TEXT

    edge_type ::Types::SubmissionBatchPublicationEdgeType
  end
end

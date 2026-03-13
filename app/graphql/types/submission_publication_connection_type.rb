# frozen_string_literal: true

module Types
  # A connection type for {SubmissionPublication}-typed records.
  #
  # @see SubmissionPublication
  # @see ::Types::SubmissionPublicationEdgeType
  # @see ::Types::SubmissionPublicationType
  class SubmissionPublicationConnectionType < Types::BaseConnection
    graphql_name "SubmissionPublicationConnection"

    description <<~TEXT
    A connection type for `SubmissionPublication`.
    TEXT

    edge_type ::Types::SubmissionPublicationEdgeType
  end
end

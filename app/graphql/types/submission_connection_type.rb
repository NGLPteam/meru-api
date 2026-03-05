# frozen_string_literal: true

module Types
  # A connection type for {Submission}-typed records.
  #
  # @see Submission
  # @see ::Types::SubmissionEdgeType
  # @see ::Types::SubmissionType
  class SubmissionConnectionType < Types::BaseConnection
    graphql_name "SubmissionConnection"

    description <<~TEXT
    A connection type for `Submission`.
    TEXT

    edge_type ::Types::SubmissionEdgeType
  end
end

# frozen_string_literal: true

module Types
  # A connection type for {SubmissionDepositTarget}-typed records.
  #
  # @see SubmissionDepositTarget
  # @see ::Types::SubmissionDepositTargetEdgeType
  # @see ::Types::SubmissionDepositTargetType
  class SubmissionDepositTargetConnectionType < Types::BaseConnection
    graphql_name "SubmissionDepositTargetConnection"

    description <<~TEXT
    A connection type for `SubmissionDepositTarget`.
    TEXT

    edge_type ::Types::SubmissionDepositTargetEdgeType
  end
end

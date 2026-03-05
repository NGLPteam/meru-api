# frozen_string_literal: true

module Types
  # A connection type for {SubmissionTarget}-typed records.
  #
  # @see SubmissionTarget
  # @see ::Types::SubmissionTargetEdgeType
  # @see ::Types::SubmissionTargetType
  class SubmissionTargetConnectionType < Types::BaseConnection
    graphql_name "SubmissionTargetConnection"

    description <<~TEXT
    A connection type for `SubmissionTarget`.
    TEXT

    edge_type ::Types::SubmissionTargetEdgeType
  end
end

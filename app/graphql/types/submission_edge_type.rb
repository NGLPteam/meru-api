# frozen_string_literal: true

module Types
  # An edge in a {::Types::SubmissionConnectionType} for {Submission}-type records.
  #
  # @see Submission
  # @see ::Types::SubmissionConnectionType
  # @see ::Types::SubmissionType
  class SubmissionEdgeType < Types::BaseEdge
    description <<~TEXT
    An edge in a connection for `Submission`.
    TEXT

    node_type ::Types::SubmissionType
  end
end

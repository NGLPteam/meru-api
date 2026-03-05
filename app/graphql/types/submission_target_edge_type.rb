# frozen_string_literal: true

module Types
  # An edge in a {::Types::SubmissionTargetConnectionType} for {SubmissionTarget}-type records.
  #
  # @see SubmissionTarget
  # @see ::Types::SubmissionTargetConnectionType
  # @see ::Types::SubmissionTargetType
  class SubmissionTargetEdgeType < Types::BaseEdge
    description <<~TEXT
    An edge in a connection for `SubmissionTarget`.
    TEXT

    node_type ::Types::SubmissionTargetType
  end
end

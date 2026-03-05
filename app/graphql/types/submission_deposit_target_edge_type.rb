# frozen_string_literal: true

module Types
  # An edge in a {::Types::SubmissionDepositTargetConnectionType} for {SubmissionDepositTarget}-type records.
  #
  # @see SubmissionDepositTarget
  # @see ::Types::SubmissionDepositTargetConnectionType
  # @see ::Types::SubmissionDepositTargetType
  class SubmissionDepositTargetEdgeType < Types::BaseEdge
    description <<~TEXT
    An edge in a connection for `SubmissionDepositTarget`.
    TEXT

    node_type ::Types::SubmissionDepositTargetType
  end
end

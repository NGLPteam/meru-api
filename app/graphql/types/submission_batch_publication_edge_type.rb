# frozen_string_literal: true

module Types
  # An edge in a {::Types::SubmissionBatchPublicationConnectionType} for {SubmissionBatchPublication}-type records.
  #
  # @see SubmissionBatchPublication
  # @see ::Types::SubmissionBatchPublicationConnectionType
  # @see ::Types::SubmissionBatchPublicationType
  class SubmissionBatchPublicationEdgeType < Types::BaseEdge
    description <<~TEXT
    An edge in a connection for `SubmissionBatchPublication`.
    TEXT

    node_type ::Types::SubmissionBatchPublicationType
  end
end

# frozen_string_literal: true

module Types
  # An edge in a {::Types::SubmissionPublicationConnectionType} for {SubmissionPublication}-type records.
  #
  # @see SubmissionPublication
  # @see ::Types::SubmissionPublicationConnectionType
  # @see ::Types::SubmissionPublicationType
  class SubmissionPublicationEdgeType < Types::BaseEdge
    description <<~TEXT
    An edge in a connection for `SubmissionPublication`.
    TEXT

    node_type ::Types::SubmissionPublicationType
  end
end

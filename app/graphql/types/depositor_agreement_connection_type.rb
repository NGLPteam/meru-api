# frozen_string_literal: true

module Types
  # A connection type for {DepositorAgreement}-typed records.
  #
  # @see DepositorAgreement
  # @see ::Types::DepositorAgreementEdgeType
  # @see ::Types::DepositorAgreementType
  class DepositorAgreementConnectionType < Types::BaseConnection
    graphql_name "DepositorAgreementConnection"

    description <<~TEXT
    A connection type for `DepositorAgreement`.
    TEXT

    edge_type ::Types::DepositorAgreementEdgeType
  end
end

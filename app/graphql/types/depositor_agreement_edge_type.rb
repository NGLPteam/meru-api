# frozen_string_literal: true

module Types
  # An edge in a {::Types::DepositorAgreementConnectionType} for {DepositorAgreement}-type records.
  #
  # @see DepositorAgreement
  # @see ::Types::DepositorAgreementConnectionType
  # @see ::Types::DepositorAgreementType
  class DepositorAgreementEdgeType < Types::BaseEdge
    description <<~TEXT
    An edge in a connection for `DepositorAgreement`.
    TEXT

    node_type ::Types::DepositorAgreementType
  end
end

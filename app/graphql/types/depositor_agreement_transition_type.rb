# frozen_string_literal: true

module Types
  # @see DepositorAgreementTransition
  # @see ::Types::DepositorAgreementTransitionConnectionType
  # @see ::Types::DepositorAgreementTransitionEdgeType
  class DepositorAgreementTransitionType < Types::AbstractModel
    description <<~TEXT
    A transition for a `DepositorAgreement`.
    TEXT

    use_direct_connection_and_edge!

    implements ::Types::CommonTransitionType

    field :from_state, Types::DepositorAgreementStateType, null: true do
      description <<~TEXT
      The state that the depositor agreement is transitioning from. This will be null if the submission target is being created.
      TEXT
    end

    field :to_state, Types::DepositorAgreementStateType, null: false do
      description <<~TEXT
      The state that the depositor agreement is transitioning to.
      TEXT
    end
  end
end

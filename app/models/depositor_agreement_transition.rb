# frozen_string_literal: true

# @see DepositorAgreement
class DepositorAgreementTransition < ApplicationRecord
  include Support::StatesmanHelpers::Transition
  include CommonTransition
  include HasEphemeralSystemSlug
  include TimestampScopes

  stateful_enum! :depositor_agreement_state

  belongs_to :depositor_agreement, inverse_of: :depositor_agreement_transitions
  belongs_to :user, inverse_of: :depositor_agreement_transitions, optional: true

  owner_association_name :depositor_agreement

  transitions_association_name :depositor_agreement_transitions
end

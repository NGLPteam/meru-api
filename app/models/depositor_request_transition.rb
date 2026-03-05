# frozen_string_literal: true

# @see DepositorRequest
class DepositorRequestTransition < ApplicationRecord
  include Support::StatesmanHelpers::Transition
  include CommonTransition
  include HasEphemeralSystemSlug
  include TimestampScopes

  stateful_enum! :depositor_request_state

  belongs_to :depositor_request, inverse_of: :depositor_request_transitions
  belongs_to :user, inverse_of: :depositor_request_transitions, optional: true

  owner_association_name :depositor_request

  transitions_association_name :depositor_request_transitions
end

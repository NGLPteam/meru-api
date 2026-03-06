# frozen_string_literal: true

# A request by a user to become a depositor for a {SubmissionTarget}.
class DepositorRequest < ApplicationRecord
  include HasEphemeralSystemSlug
  include TimestampScopes
  include UsesStatesman

  pg_enum! :state, as: :depositor_request_state, allow_blank: false, default: "pending"

  has_state_machine! predicates: :ALL

  belongs_to :submission_target, inverse_of: :depositor_requests
  belongs_to :user, inverse_of: :depositor_requests

  scope :in_default_order, -> { order(created_at: :desc) }

  delegate :entity, to: :submission_target, prefix: :target

  validates :user_id, uniqueness: { scope: :submission_target_id }

  # @see Access::Grant
  monadic_operation! def add_depositor
    call_operation("access.grant", Role.fetch(:depositor), on: target_entity, to: user)
  end

  # @see Access::Revoke
  monadic_operation! def remove_depositor
    call_operation("access.revoke", Role.fetch(:depositor), on: target_entity, to: user)
  end
end

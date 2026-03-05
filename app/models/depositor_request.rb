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

  has_one :target_entity, through: :submission_target, source: :entity

  validates :user_id, uniqueness: { scope: :submission_target_id }
end

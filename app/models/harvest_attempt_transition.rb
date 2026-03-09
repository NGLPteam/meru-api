# frozen_string_literal: true

# @see HarvestAttempt
class HarvestAttemptTransition < ApplicationRecord
  include GenericAccessible
  include TimestampScopes

  belongs_to :harvest_attempt, inverse_of: :harvest_attempt_transitions

  after_destroy :update_most_recent!, if: :most_recent?

  private

  # @return [void]
  def update_most_recent!
    # :nocov:
    last_transition = harvest_attempt.harvest_attempt_transitions.order(:sort_key).last

    return if last_transition.blank?

    last_transition.update_column(:most_recent, true)
    # :nocov:
  end
end

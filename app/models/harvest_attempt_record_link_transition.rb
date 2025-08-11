# frozen_string_literal: true

# @see HarvestAttemptRecordLink
class HarvestAttemptRecordLinkTransition < ApplicationRecord
  include TimestampScopes

  belongs_to :harvest_attempt_record_link, inverse_of: :harvest_attempt_record_link_transitions

  after_destroy :update_most_recent!, if: :most_recent?

  private

  # @return [void]
  def update_most_recent!
    last_transition = harvest_attempt_record_link.harvest_attempt_record_link_transitions.order(:sort_key).last

    return if last_transition.blank?

    last_transition.update_column(:most_recent, true)
  end
end

# frozen_string_literal: true

# @see HarvestAttemptEntityLink
class HarvestAttemptEntityLinkTransition < ApplicationRecord
  include TimestampScopes

  belongs_to :harvest_attempt_entity_link, inverse_of: :harvest_attempt_entity_link_transitions

  after_destroy :update_most_recent!, if: :most_recent?

  private

  # @return [void]
  def update_most_recent!
    last_transition = harvest_attempt_entity_link.harvest_attempt_entity_link_transitions.order(:sort_key).last

    return if last_transition.blank?

    last_transition.update_column(:most_recent, true)
  end
end

# frozen_string_literal: true

# A connection between a {HarvestAttempt} and a {HarvestEntity}.
class HarvestAttemptEntityLink < ApplicationRecord
  include TimestampScopes
  include UsesStatesman

  has_state_machine! machine_class: Harvesting::Attempts::EntityLinks::StateMachine

  belongs_to :harvest_attempt, inverse_of: :harvest_attempt_entity_links
  belongs_to :harvest_entity, inverse_of: :harvest_attempt_entity_links

  belongs_to_readonly :harvest_attempt_record_link, inverse_of: :harvest_attempt_entity_links,
    primary_key: %i[harvest_attempt_id harvest_record_id],
    foreign_key: %i[harvest_attempt_id harvest_record_id],
    optional: true

  # @see HarvestAttemptRecordLink#check_for_success!
  # @return [void]
  def check_record_for_success!
    harvest_attempt_record_link.try :check_for_success!
  end
end

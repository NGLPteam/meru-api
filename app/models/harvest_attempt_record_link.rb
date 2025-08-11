# frozen_string_literal: true

# A connection between a {HarvestAttempt} and a {HarvestRecord}.
class HarvestAttemptRecordLink < ApplicationRecord
  include TimestampScopes
  include UsesStatesman

  has_state_machine! machine_class: Harvesting::Attempts::RecordLinks::StateMachine

  belongs_to :harvest_attempt, inverse_of: :harvest_attempt_record_links
  belongs_to :harvest_record, inverse_of: :harvest_attempt_record_links

  has_many_readonly :harvest_attempt_entity_links, inverse_of: :harvest_attempt_record_link,
    primary_key: %i[harvest_attempt_id harvest_record_id],
    foreign_key: %i[harvest_attempt_id harvest_record_id]

  # @return [void]
  def check_for_success!
    total = harvest_attempt_entity_links.count
    done = harvest_attempt_entity_links.in_state(:success).count

    return unless total == done && can_transition_to?(:upserted)

    transition_to(:upserted)
  end
end

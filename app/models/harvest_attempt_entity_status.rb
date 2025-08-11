# frozen_string_literal: true

class HarvestAttemptEntityStatus < ApplicationRecord
  include HasEphemeralSystemSlug

  self.primary_key = :harvest_attempt_id

  belongs_to_readonly :harvest_attempt, inverse_of: :harvest_attempt_entity_status
end

# frozen_string_literal: true

class HarvestAttemptRecordStatus < ApplicationRecord
  include HasEphemeralSystemSlug

  self.primary_key = :harvest_attempt_id

  belongs_to_readonly :harvest_attempt, inverse_of: :harvest_attempt_record_status
end

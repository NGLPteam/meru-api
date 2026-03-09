# frozen_string_literal: true

class LatestHarvestAttemptLink < ApplicationRecord
  include GenericInaccessible
  include View

  belongs_to_readonly :harvest_source, inverse_of: :latest_harvest_attempt_links
  belongs_to_readonly :harvest_set, inverse_of: :latest_harvest_attempt_links
  belongs_to_readonly :harvest_mapping, inverse_of: :latest_harvest_attempt_link
  belongs_to_readonly :harvest_attempt, inverse_of: :latest_harvest_attempt_link
end

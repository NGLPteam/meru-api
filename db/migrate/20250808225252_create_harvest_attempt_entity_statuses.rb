class CreateHarvestAttemptEntityStatuses < ActiveRecord::Migration[7.2]
  def change
    create_view :harvest_attempt_entity_statuses
  end
end

class CreateHarvestAttemptRecordStatuses < ActiveRecord::Migration[7.2]
  def change
    create_view :harvest_attempt_record_statuses
  end
end

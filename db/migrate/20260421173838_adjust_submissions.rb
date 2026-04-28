# frozen_string_literal: true

class AdjustSubmissions < ActiveRecord::Migration[8.1]
  def change
    change_table :submission_targets do |t|
      t.boolean :auto_approve_depositors, null: false, default: false
    end

    change_table :submissions do |t|
      t.timestamp :agreement_accepted_at
    end

    change_table :schema_version_properties do |t|
      t.boolean :submittable, null: false, default: false
    end
  end
end

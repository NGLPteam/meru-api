# frozen_string_literal: true

class CreateTunerMetrics < ActiveRecord::Migration[7.2]
  def change
    create_table :tuner_metrics, id: :uuid do |t|
      t.citext :name
      t.bigint :value

      t.timestamps null: false, default: -> { "CURRENT_TIMESTAMP" }
    end
  end
end

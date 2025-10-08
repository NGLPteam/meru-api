# frozen_string_literal: true

class CreateTunerSuggestions < ActiveRecord::Migration[7.2]
  def change
    create_table :tuner_suggestions, id: :uuid do |t|
      t.text :report

      t.timestamps null: false, default: -> { "CURRENT_TIMESTAMP" }

      t.index :report, unique: true
    end
  end
end

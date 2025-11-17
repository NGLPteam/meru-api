# frozen_string_literal: true

class CreateRequestSteps < ActiveRecord::Migration[7.2]
  def change
    change_table :request_timings do |t|
      t.uuid :request_id, null: true
    end

    create_table :request_steps, id: :uuid do |t|
      t.references :request_query, type: :uuid, null: false, foreign_key: { on_delete: :cascade }

      t.uuid :request_id, null: true

      t.text :name, null: false
      t.text :current_path, null: true

      t.decimal :duration, null: false

      t.timestamps null: false, default: -> { "CURRENT_TIMESTAMP" }
    end
  end
end

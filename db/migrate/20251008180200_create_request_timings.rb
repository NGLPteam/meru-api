# frozen_string_literal: true

class CreateRequestTimings < ActiveRecord::Migration[7.2]
  def change
    create_enum :request_query_kind, %w[query mutation subscription other]

    create_table :request_queries, id: :uuid do |t|
      t.enum :kind, enum_type: :request_query_kind, default: :query, null: false

      t.text :query, null: false

      t.text :digest, null: false

      t.text :operation_name, null: true

      t.timestamps null: false, default: -> { "CURRENT_TIMESTAMP" }
    end

    create_table :request_timings, id: :uuid do |t|
      t.references :request_query, type: :uuid, null: false, foreign_key: { on_delete: :cascade }
  
      t.decimal :duration, null: false

      t.jsonb :variables

      t.timestamps null: false, default: -> { "CURRENT_TIMESTAMP" }
    end
  end
end

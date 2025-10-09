# frozen_string_literal: true

class CreateCacheWarmings < ActiveRecord::Migration[7.2]
  def change
    create_table :cache_warmings, id: :uuid do |t|
      t.references :cache_warmer, null: false, foreign_key: { on_delete: :cascade }, type: :uuid
      t.integer :status
      t.decimal :duration

      t.text :url, null: false
      t.text :error_klass
      t.text :error_message

      t.timestamps null: false, default: -> { "CURRENT_TIMESTAMP" }
    end
  end
end

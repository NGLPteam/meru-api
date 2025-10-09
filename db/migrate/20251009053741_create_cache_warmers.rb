# frozen_string_literal: true

class CreateCacheWarmers < ActiveRecord::Migration[7.2]
  def change
    create_table :cache_warmers, id: :uuid do |t|
      t.references :warmable, polymorphic: true, null: false, type: :uuid, index: { unique: true }

      t.timestamps null: false, default: -> { "CURRENT_TIMESTAMP" }
    end
  end
end

# frozen_string_literal: true

class AddRefreshedAtToCachedEntityLists < ActiveRecord::Migration[7.2]
  def change
    change_table :templates_cached_entity_lists do |t|
      t.timestamp :refreshed_at, null: true

      t.index :refreshed_at
    end
  end
end

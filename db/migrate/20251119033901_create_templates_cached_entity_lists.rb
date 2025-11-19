# frozen_string_literal: true

class CreateTemplatesCachedEntityLists < ActiveRecord::Migration[7.2]
  def change
    create_table :templates_cached_entity_lists, id: :uuid do |t|
      t.references :template_instance, polymorphic: true, null: false, type: :uuid, index: { unique: true, name: "index_cached_entity_list_uniqueness" }
      t.references :entity, polymorphic: true, null: false, type: :uuid

      t.integer :count, null: false, default: 0
      t.boolean :empty, null: false, default: false
      t.boolean :fallback, null: false, default: false
      t.boolean :flat_depth, null: false, default: false
      t.integer :maximum_depth, null: true
      t.integer :minimum_depth, null: true

      t.timestamps null: false, default: -> { "CURRENT_TIMESTAMP" }
    end
  end
end

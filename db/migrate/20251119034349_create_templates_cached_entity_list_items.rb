# frozen_string_literal: true

class CreateTemplatesCachedEntityListItems < ActiveRecord::Migration[7.2]
  def change
    create_table :templates_cached_entity_list_items, id: :uuid do |t|
      t.references :cached_entity_list, null: false, foreign_key: { to_table: :templates_cached_entity_lists, on_delete: :cascade }, type: :uuid, index: false
      t.references :list_item_layout_instance, null: false, foreign_key: { to_table: :layouts_list_item_instances, on_delete: :cascade }, type: :uuid
      t.references :schema_version, null: false, foreign_key: { on_delete: :cascade }, type: :uuid
      t.references :entity, polymorphic: true, null: false, type: :uuid

      t.bigint :position, null: false
  
      t.timestamps null: false, default: -> { "CURRENT_TIMESTAMP" }

      t.index %i[cached_entity_list_id position], name: "index_cached_entity_list_items_uniqueness", unique: true
    end
  end
end

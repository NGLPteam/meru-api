# frozen_string_literal: true

class AddPostProcessingToLayoutInstances < ActiveRecord::Migration[7.2]
  LAYOUT_TABLES = %i[
    layouts_hero_instances
    layouts_list_item_instances
    layouts_main_instances
    layouts_metadata_instances
    layouts_navigation_instances
    layouts_supplementary_instances
  ].freeze

  def change
    LAYOUT_TABLES.each do |table_name|
      change_table table_name do |t|
        t.timestamp :post_processed_at

        t.boolean :all_hidden, null: false, default: false

        t.boolean :all_slots_empty, null: false, default: false
      end
    end

    change_table :layouts_instance_digests do |t|
      t.timestamp :post_processed_at

      t.boolean :all_hidden, null: false, default: false

      t.boolean :all_slots_empty, null: false, default: false
    end
  end
end

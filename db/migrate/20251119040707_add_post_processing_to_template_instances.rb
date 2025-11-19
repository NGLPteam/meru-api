# frozen_string_literal: true

class AddPostProcessingToTemplateInstances < ActiveRecord::Migration[7.2]
  TEMPLATE_TABLES = %i[
    templates_blurb_instances
    templates_contributor_list_instances
    templates_descendant_list_instances
    templates_detail_instances
    templates_hero_instances
    templates_link_list_instances
    templates_list_item_instances
    templates_metadata_instances
    templates_navigation_instances
    templates_ordering_instances
    templates_page_list_instances
    templates_supplementary_instances
  ].freeze

  HAS_ENTITY_LIST_TABLES = %i[
    templates_descendant_list_instances
    templates_link_list_instances
    templates_list_item_instances
  ].freeze

  def change
    TEMPLATE_TABLES.each do |table_name|
      change_table table_name do |t|
        t.timestamp :post_processed_at

        t.boolean :all_slots_empty, null: false, default: false

        t.boolean :allow_hide, null: false, default: true

        t.boolean :hidden, null: false, default: false

        t.boolean :hidden_by_empty_slots, null: false, default: false

        if table_name.in?(HAS_ENTITY_LIST_TABLES)
          t.boolean :hidden_by_entity_list, null: false, default: false

          t.timestamp :entity_list_cached_at
        end
      end
    end

    change_table :templates_instance_digests do |t|
      t.timestamp :post_processed_at

      t.boolean :all_slots_empty, null: false, default: false

      t.boolean :allow_hide, null: false, default: true

      t.boolean :hidden, null: false, default: false
    end

    reversible do |dir|
      dir.up do
        say_with_time "Creating initial empty entity lists for existing template instances" do
          exec_update(<<~SQL)
          WITH raw_lists AS (
            SELECT 'Templates::DescendantListInstance'::text AS template_instance_type, id AS template_instance_id,
              entity_type, entity_id
            FROM templates_descendant_list_instances
            UNION ALL
            SELECT 'Templates::LinkListInstance'::text AS template_instance_type, id AS template_instance_id,
              entity_type, entity_id
            FROM templates_link_list_instances
            UNION ALL
            SELECT 'Templates::ListItemInstance'::text AS template_instance_type, id AS template_instance_id,
              entity_type, entity_id
            FROM templates_list_item_instances
          )
          INSERT INTO templates_cached_entity_lists (template_instance_type, template_instance_id, entity_type, entity_id, created_at, updated_at)
          SELECT template_instance_type, template_instance_id, entity_type, entity_id, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP
          FROM raw_lists;
          SQL
        end

        TEMPLATE_TABLES.each do |table_name|
          say_with_time "Setting hidden flags on existing #{table_name} records" do
            listy = table_name.in?(HAS_ENTITY_LIST_TABLES) && table_name != "templates_list_item_instances"

            exec_update(<<~SQL)
            UPDATE #{table_name}
            SET
              post_processed_at = CURRENT_TIMESTAMP,
              all_slots_empty = FALSE,
              allow_hide = TRUE,
              hidden_by_empty_slots = FALSE,
              hidden = #{listy ? "TRUE" : "FALSE"}
            #{", hidden_by_entity_list = TRUE, entity_list_cached_at = CURRENT_TIMESTAMP" if listy};
            SQL
          end
        end

        say_with_time "Setting hidden flags on existing entity list template instance digests" do
          exec_update(<<~SQL)
          UPDATE templates_instance_digests
          SET
            post_processed_at = CURRENT_TIMESTAMP,
            all_slots_empty = FALSE,
            allow_hide = TRUE,
            hidden = TRUE
          WHERE template_instance_type IN ('Templates::DescendantListInstance', 'Templates::LinkListInstance');
          SQL
        end
      end
    end
  end
end

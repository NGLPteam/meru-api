# frozen_string_literal: true

class CreateHarvestAttemptEntityLinks < ActiveRecord::Migration[7.2]
  def change
    change_table :harvest_attempt_record_links do |t|
      t.decimal :extraction_duration, null: false, default: 0.0
    end

    create_table :harvest_attempt_entity_links, id: :uuid do |t|
      t.references :harvest_attempt, null: false, foreign_key: { on_delete: :cascade }, type: :uuid
      t.references :harvest_entity, null: false, foreign_key: { on_delete: :cascade }, type: :uuid
      t.references :harvest_record, null: false, foreign_key: { on_delete: :cascade }, type: :uuid

      t.boolean :assets, null: false, default: false

      t.decimal :upsert_duration, null: false, default: 0.0
      t.decimal :assets_duration, null: false, default: 0.0

      t.timestamps null: false, default: -> { "CURRENT_TIMESTAMP" }

      t.index %i[harvest_attempt_id harvest_entity_id], unique: true, name: "index_harvest_attempt_entity_links_uniqueness"
    end

    reversible do |dir|
      dir.up do
        say_with_time "Backporting harvest_attempt_entity_links" do
          exec_update(<<~SQL)
          WITH raw_links AS (
            SELECT harvest_attempt_id, he.id AS harvest_entity_id, harvest_record_id
            FROM harvest_attempt_record_links harl
            INNER JOIN harvest_entities he USING (harvest_record_id)
          )
          INSERT INTO harvest_attempt_entity_links (harvest_attempt_id, harvest_entity_id, harvest_record_id)
          SELECT harvest_attempt_id, harvest_entity_id, harvest_record_id FROM raw_links
          ON CONFLICT (harvest_attempt_id, harvest_entity_id) DO NOTHING;
          SQL
        end
      end
    end
  end
end

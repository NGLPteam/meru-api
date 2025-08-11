# frozen_string_literal: true

class CreateHarvestAttemptEntityLinkTransitions < ActiveRecord::Migration[7.2]
  def change
    create_table :harvest_attempt_entity_link_transitions, id: :uuid do |t|
      t.references :harvest_attempt_entity_link, null: false, type: :uuid, foreign_key: { on_delete: :cascade }, index: false
      t.boolean :most_recent, null: false
      t.integer :sort_key, null: false
      t.string :to_state, null: false
      t.jsonb :metadata

      t.timestamps null: false, default: -> { "CURRENT_TIMESTAMP" }

      t.index %i(harvest_attempt_entity_link_id sort_key), unique: true, name: "index_harvest_attempt_entity_link_transitions_parent_sort"
      t.index %i(harvest_attempt_entity_link_id most_recent), unique: true, where: "most_recent", name: "index_herl_transitions_parent_most_recent"
    end

    reversible do |dir|
      dir.up do
        say_with_time "Backporting harvest_attempt_entity_link_transitions" do
          exec_update(<<~SQL)
          WITH raw_transitions AS (
            SELECT links.id AS harvest_attempt_entity_link_id,
              TRUE AS most_recent,
              10 AS sort_key,
              'success' AS to_state,
              jsonb_build_object('backported', true) AS metadata
            FROM harvest_attempt_entity_links links
          )
          INSERT INTO harvest_attempt_entity_link_transitions (harvest_attempt_entity_link_id, most_recent, sort_key, to_state, metadata)
          SELECT harvest_attempt_entity_link_id, most_recent, sort_key, to_state, metadata FROM raw_transitions;
          SQL
        end
      end
    end
  end
end

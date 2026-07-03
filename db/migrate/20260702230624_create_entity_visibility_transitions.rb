# frozen_string_literal: true

class CreateEntityVisibilityTransitions < ActiveRecord::Migration[8.1]
  def change
    create_enum :entity_visibility_state, %w[visible hidden]

    change_table :entity_visibilities, bulk: true do |t|
      t.enum :state, enum_type: :entity_visibility_state, null: false, default: "visible"

      t.index :state
    end

    create_table :entity_visibility_transitions, id: :uuid do |t|
      t.references :entity_visibility, null: false, type: :uuid, foreign_key: { on_delete: :cascade }, index: false
      t.boolean :most_recent, null: false
      t.integer :sort_key, null: false
      t.enum :from_state, enum_type: :entity_visibility_state, null: true
      t.enum :to_state, enum_type: :entity_visibility_state, null: false
      t.jsonb :metadata

      t.timestamps null: false, default: -> { "CURRENT_TIMESTAMP" }

      t.index %i(entity_visibility_id sort_key), unique: true, name: "index_entity_visibility_transitions_parent_sort"
      t.index %i(entity_visibility_id most_recent), unique: true, where: "most_recent", name: "index_entity_visibility_transitions_parent_most_recent"
    end

    reversible do |dir|
      dir.up do
        say_with_time "Marking hidden states" do
          exec_update <<~SQL
          UPDATE entity_visibilities
          SET state = 'hidden'
          WHERE
          CASE visibility
          WHEN 'hidden' THEN true
          WHEN 'limited' THEN NOT (visibility_range @> CURRENT_TIMESTAMP)
          ELSE
            false
          END
          SQL
        end

        say_with_time "Creating initial transitions" do
          exec_update <<~SQL
          WITH initial_transitions AS (
            SELECT
              id AS entity_visibility_id,
              NULL::entity_visibility_state AS from_state,
              'visible'::entity_visibility_state AS to_state,
              10 AS sort_key,
              state = 'visible' AS most_recent,
              created_at,
              updated_at
            FROM entity_visibilities
          ), hidden_transitions AS (
            SELECT
              id AS entity_visibility_id,
              'visible'::entity_visibility_state AS from_state,
              'hidden'::entity_visibility_state AS to_state,
              20 AS sort_key,
              TRUE as most_recent,
              updated_at,
              updated_at
            FROM entity_visibilities
            WHERE state = 'hidden'
          ), all_transitions AS (
            SELECT * FROM initial_transitions
            UNION ALL
            SELECT * FROM hidden_transitions
          )
          INSERT INTO entity_visibility_transitions
            (entity_visibility_id, from_state, to_state, sort_key, most_recent, created_at, updated_at)
          SELECT entity_visibility_id, from_state, to_state, sort_key, most_recent, created_at, updated_at
          FROM all_transitions
          SQL
        end
      end
    end
  end
end

# frozen_string_literal: true

class AllowContributorsToBeMerged < ActiveRecord::Migration[8.1]
  def change
    create_enum :contributor_merge_source_status, %w[unmerged merging merged]
    create_enum :contributor_merge_target_status, %w[inactive active]

    change_table :contributors do |t|
      t.references :merge_target, foreign_key: { to_table: :contributors, on_delete: :nullify }, null: true, type: :uuid

      t.enum :merge_source_status, enum_type: "contributor_merge_source_status", null: false, default: "unmerged"
      t.enum :merge_target_status, enum_type: "contributor_merge_target_status", null: false, default: "inactive"

      t.check_constraint <<~SQL, name: "merge_target_cannot_be_self"
      merge_target_id IS NULL OR merge_target_id <> id
      SQL
    end

    change_table :global_configurations do |t|
      t.jsonb :contributors, null: false, default: {}
    end

    change_table :harvest_contributors do |t|
      t.boolean :merged, null: false, default: false
    end

    reversible do |dir|
      dir.up do
        execute <<~SQL
        UPDATE global_configurations SET contributors = jsonb_build_object(
          'claimable', true,
          'owner_updatable', true
        )
        SQL
      end
    end
  end
end

# frozen_string_literal: true

class TableizeEntityAncestors < ActiveRecord::Migration[7.2]
  def up
    drop_view :entity_ancestors

    create_table :entity_ancestors, id: :uuid do |t|
      t.references :entity, type: :uuid, polymorphic: true, null: false, index: false
      t.references :ancestor, type: :uuid, polymorphic: true, null: false
      t.references :ancestor_schema_version, type: :uuid, null: false, foreign_key: { to_table: :schema_versions, on_delete: :restrict }
      t.text :name, null: false

      t.bigint :origin_depth, null: false
      t.bigint :ancestor_depth, null: false
      t.bigint :relative_depth, null: false

      t.timestamps null: false, default: -> { "CURRENT_TIMESTAMP" }

      t.index %i[entity_id name], name: "index_entity_ancestors_uniqueness", unique: true
    end

    say_with_time "Populating entity_ancestors table" do
      exec_update(<<~SQL)
      MERGE INTO entity_ancestors ea
      USING entity_derived_ancestors eda ON (ea.entity_id = eda.entity_id AND ea.name = eda.name)
      WHEN MATCHED AND (
        ea.entity_type <> eda.entity_type
        OR
        ea.ancestor_type <> eda.ancestor_type
        OR
        ea.ancestor_id <> eda.ancestor_id
        OR
        ea.ancestor_schema_version_id <> eda.ancestor_schema_version_id
        OR
        ea.origin_depth <> eda.origin_depth
        OR
        ea.ancestor_depth <> eda.ancestor_depth
        OR
        ea.relative_depth <> eda.relative_depth
      ) THEN UPDATE SET
        entity_type = eda.entity_type,
        ancestor_type = eda.ancestor_type,
        ancestor_id = eda.ancestor_id,
        ancestor_schema_version_id = eda.ancestor_schema_version_id,
        origin_depth = eda.origin_depth,
        ancestor_depth = eda.ancestor_depth,
        relative_depth = eda.relative_depth,
        updated_at = CURRENT_TIMESTAMP
      WHEN NOT MATCHED THEN INSERT (
        entity_type,
        entity_id,
        ancestor_type,
        ancestor_id,
        ancestor_schema_version_id,
        name,
        origin_depth,
        ancestor_depth,
        relative_depth
      ) VALUES (
        eda.entity_type,
        eda.entity_id,
        eda.ancestor_type,
        eda.ancestor_id,
        eda.ancestor_schema_version_id,
        eda.name,
        eda.origin_depth,
        eda.ancestor_depth,
        eda.relative_depth
      );
      SQL
    end
  end

  def down
    drop_table :entity_ancestors

    create_view :entity_ancestors, version: 1
  end
end

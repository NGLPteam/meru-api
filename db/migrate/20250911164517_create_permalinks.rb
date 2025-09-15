# frozen_string_literal: true

class CreatePermalinks < ActiveRecord::Migration[7.2]
  def change
    create_enum :permalinkable_kind, %w[community collection item]

    create_table :permalinks, id: :uuid do |t|
      t.references :permalinkable, type: :uuid, null: false, polymorphic: true

      t.boolean :canonical, null: false, default: false

      t.enum :kind, enum_type: :permalinkable_kind, null: false

      t.citext :uri, null: false

      t.citext :permalinkable_slug, null: false

      t.timestamps null: false, default: -> { "CURRENT_TIMESTAMP" }

      t.index :uri, unique: true

      t.index %i[permalinkable_type permalinkable_id], unique: true, name: "index_permalinks_on_canonical_permalinkable", where: "canonical"

      t.index %i[canonical uri], name: "index_permalinks_ordering", order: { canonical: :desc, uri: :asc }
    end
  end
end

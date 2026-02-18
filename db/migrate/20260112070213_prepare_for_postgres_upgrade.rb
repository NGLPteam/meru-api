# frozen_string_literal: true

class PrepareForPostgresUpgrade < ActiveRecord::Migration[7.2]
  def up
    execute <<~SQL
    ALTER TABLE schematic_texts DROP COLUMN IF EXISTS document;
    SQL

    execute <<~SQL
    ALTER TABLE schematic_texts ALTER COLUMN dictionary DROP DEFAULT;
    ALTER TABLE schematic_texts ALTER COLUMN dictionary SET DATA TYPE meru_dictionary USING public.meru_safe_dictionary(dictionary::text);
    ALTER TABLE schematic_texts ALTER COLUMN dictionary SET DEFAULT 'simple'::meru_dictionary;
    SQL

    change_table :schematic_texts do |t|
      t.virtual :document, type: :tsvector,
        as: "public.meru_tsvector(dictionary, text_content, weight)",
        stored: true,
        null: true

      t.index :document, using: :gin
    end
  end

  def down
    execute <<~SQL
    ALTER TABLE schematic_texts DROP COLUMN IF EXISTS document;
    SQL

    execute <<~SQL
    ALTER TABLE schematic_texts ALTER COLUMN dictionary DROP DEFAULT;
    ALTER TABLE schematic_texts ALTER COLUMN dictionary SET DATA TYPE text USING dictionary::text;
    ALTER TABLE schematic_texts ALTER COLUMN dictionary SET DEFAULT 'simple'::text;
    SQL

    change_table :schematic_texts do |t|
      t.virtual :document, type: :tsvector,
        as: %[setweight(to_tsvector('simple', COALESCE(text_content, '')), (weight)::"char")],
        stored: true,
        null: true

      t.index :document, using: :gin
    end
  end
end

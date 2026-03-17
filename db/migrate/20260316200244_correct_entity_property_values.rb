# frozen_string_literal: true

class CorrectEntityPropertyValues < ActiveRecord::Migration[8.1]
  TABLES = %i[
    communities
    collections
    items
  ].freeze

  def change
    reversible do |dir|
      dir.up do
        execute <<~SQL
        CREATE FUNCTION public.entity_property_values_valid(jsonb) RETURNS boolean AS $$
        SELECT $1 IS NOT NULL AND ($1 -> 'values' IS NULL OR jsonb_typeof($1 -> 'values') = 'object');
        $$ LANGUAGE SQL IMMUTABLE CALLED ON NULL INPUT PARALLEL SAFE;

        COMMENT ON FUNCTION public.entity_property_values_valid(jsonb) IS 'Check that the given JSONB object has a "values" key of the correct type (object or null).';
        SQL

        TABLES.each do |table|
          exec_update(<<~SQL, "Correct #{table}.properties.values")
          UPDATE #{table} SET
          properties = jsonb_set(properties, '{values}', (properties ->> 'values')::jsonb)
          WHERE properties ? 'values' AND jsonb_typeof(properties -> 'values') = 'string';
          SQL
        end
      end

      dir.down do
        execute "DROP FUNCTION public.entity_property_values_valid(jsonb);"
      end
    end

    TABLES.each do |table|
      change_table table do |t|
        t.check_constraint <<~SQL, name: "chk_#{table}_property_values_safeguard"
        public.entity_property_values_valid(properties)
        SQL
      end
    end
  end
end

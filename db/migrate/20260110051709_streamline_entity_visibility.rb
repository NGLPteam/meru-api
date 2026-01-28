# frozen_string_literal: true

class StreamlineEntityVisibility < ActiveRecord::Migration[7.2]
  def change
    change_table :entity_visibilities do |t|
      t.boolean :active, null: false, default: false

      t.index %i[entity_type entity_id active],
        name: "index_entity_visibilities_active"
    end

    reversible do |dir|
      dir.up do
        execute(<<~SQL)
        CREATE FUNCTION public.entity_visibility_active(public.entity_visibility, tstzrange, timestamp with time zone) RETURNS boolean AS $$
        SELECT
          CASE $1
          WHEN 'visible' THEN TRUE
          WHEN 'hidden' THEN FALSE
          WHEN 'limited' THEN $2 IS NOT NULL AND $3 IS NOT NULL AND $2 @> $3
          ELSE FALSE END
        $$ LANGUAGE SQL IMMUTABLE PARALLEL SAFE;
        SQL

        say_with_time "Updating entity visibility active flags" do
          exec_update(<<~SQL)
          UPDATE entity_visibilities
            SET active = public.entity_visibility_active(visibility, visibility_range, CURRENT_TIMESTAMP)
          ;
          SQL
        end
      end

      dir.down do
        execute(<<~SQL)
        DROP FUNCTION public.entity_visibility_active(public.entity_visibility, tstzrange, timestamp with time zone);
        SQL
      end
    end
  end
end

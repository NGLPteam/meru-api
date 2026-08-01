# frozen_string_literal: true

class AddChronologicalDateToHarvestAttempts < ActiveRecord::Migration[8.1]
  def change
    reversible do |dir|
      dir.up do
        execute <<~SQL
        DROP INDEX IF EXISTS harvest_attempts_scheduling_uniqueness;

        ALTER TABLE harvest_attempts ALTER COLUMN mode DROP DEFAULT;

        ALTER TABLE harvest_attempts
        ALTER COLUMN mode SET DATA TYPE public.harvest_schedule_mode USING
        CASE mode::text
        WHEN 'scheduled'::text then 'scheduled'::harvest_schedule_mode
        ELSE 'manual'::harvest_schedule_mode
        END;

        ALTER TABLE harvest_attempts ALTER COLUMN mode SET DEFAULT 'manual'::harvest_schedule_mode;

        CREATE UNIQUE INDEX harvest_attempts_scheduling_uniqueness
        ON harvest_attempts (harvest_mapping_id, scheduling_key)
        WHERE (
          mode = 'scheduled'::public.harvest_schedule_mode
          AND harvest_mapping_id IS NOT NULL
          AND scheduling_key IS NOT NULL
        );
        SQL
      end

      dir.down do
        execute <<~SQL
        DROP INDEX IF EXISTS harvest_attempts_scheduling_uniqueness;

        ALTER TABLE harvest_attempts ALTER COLUMN mode DROP DEFAULT;

        ALTER TABLE harvest_attempts
        ALTER COLUMN mode SET DATA TYPE text USING mode::text;

        ALTER TABLE harvest_attempts ALTER COLUMN mode SET DEFAULT 'manual'::text;

        CREATE UNIQUE INDEX harvest_attempts_scheduling_uniqueness
        ON harvest_attempts (harvest_mapping_id, scheduling_key)
        WHERE (
          mode = 'scheduled'::text
          AND harvest_mapping_id IS NOT NULL
          AND scheduling_key IS NOT NULL
        );
        SQL
      end
    end

    change_table :harvest_attempts do |t|
      t.virtual :sorted_at, type: :timestamp, stored: true, null: false, as: <<~SQL
      CASE mode
      WHEN 'scheduled' THEN
        GREATEST(created_at, scheduled_at)
      ELSE
        GREATEST(created_at, began_at)
      END
      SQL

      t.index :sorted_at
    end
  end
end

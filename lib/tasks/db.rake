# frozen_string_literal: true

namespace :db do
  namespace :collation do
    desc "Refresh all collations with version mismatches and reindex dependent objects"
    task refresh: :environment do
      connection = ActiveRecord::Base.connection

      # Find all collations with version mismatches (PG 13+)
      stale_collations = connection.select_all(<<~SQL)
        SELECT
          n.nspname AS schema_name,
          c.collname AS collation_name,
          c.collversion AS stored_version,
          pg_collation_actual_version(c.oid) AS actual_version
        FROM pg_collation c
        JOIN pg_namespace n ON c.collnamespace = n.oid
        WHERE c.collversion IS NOT NULL
          AND c.collversion <> pg_collation_actual_version(c.oid)
      SQL

      if stale_collations.empty?
        puts "✅ All collations are up to date."
        next
      end

      stale_collations.each do |row|
        schema   = row["schema_name"]
        name     = row["collation_name"]
        stored   = row["stored_version"]
        actual   = row["actual_version"]
        quoted   = "#{connection.quote_table_name(schema)}.#{connection.quote_column_name(name)}"

        puts "⚠️  Collation #{quoted}: stored=#{stored}, actual=#{actual}"

        # Find and reindex all indexes that use this collation
        dependent_indexes = connection.select_values(<<~SQL)
          SELECT DISTINCT indexrelid::regclass::text
          FROM pg_index
          JOIN pg_depend ON pg_depend.objid = pg_index.indexrelid
          WHERE pg_depend.refobjid = (
            SELECT oid FROM pg_collation
            WHERE collname = #{connection.quote(name)}
              AND collnamespace = (SELECT oid FROM pg_namespace WHERE nspname = #{connection.quote(schema)})
          )
        SQL

        if dependent_indexes.any?
          puts "   Reindexing #{dependent_indexes.size} dependent index(es)..."
          dependent_indexes.each do |idx|
            puts "   → REINDEX INDEX #{idx}"
            connection.execute("REINDEX INDEX #{idx}")
          end
        else
          puts "   No dependent indexes found via pg_depend. Running full REINDEX as a safety measure..."
          connection.execute("REINDEX DATABASE #{connection.quote_table_name(connection.current_database)}")
        end

        puts "   → ALTER COLLATION #{quoted} REFRESH VERSION"
        connection.execute("ALTER COLLATION #{quoted} REFRESH VERSION")
        puts "   ✅ Done."
      end
    end
  end
end

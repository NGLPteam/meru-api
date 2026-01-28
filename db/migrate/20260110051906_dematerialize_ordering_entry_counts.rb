# frozen_string_literal: true

# We're updating the ordering entry counts view to no longer be materialized.
# The data will be denormalized and stored directly on the orderings table.
class DematerializeOrderingEntryCounts < ActiveRecord::Migration[7.2]
  def up
    execute <<~SQL
    DROP INDEX IF EXISTS index_orderings_for_initial;
    DROP TABLE IF EXISTS initial_ordering_links;
    DROP TABLE IF EXISTS initial_ordering_selections;
    DROP VIEW IF EXISTS initial_ordering_derivations;
    SQL

    drop_view :ordering_entry_counts, materialized: true

    create_view :ordering_entry_counts, version: 2
  end

  def down
    drop_view :ordering_entry_counts

    create_view :ordering_entry_counts, version: 1, materialized: true

    change_table :ordering_entry_counts do |t|
      t.index %i[ordering_id], name: "ordering_entry_counts_pkey", unique: true
    end
  end
end

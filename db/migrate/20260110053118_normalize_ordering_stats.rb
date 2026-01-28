# frozen_string_literal: true

class NormalizeOrderingStats < ActiveRecord::Migration[7.2]
  def change
    change_table :orderings do |t|
      t.bigint :visible_count, null: false, default: 0
      t.bigint :entries_count, null: false, default: 0

      t.column :oldest_published, :variable_precision_date, null: true, default: -> { "'(,none)'" }
      t.column :latest_published, :variable_precision_date, null: true, default: -> { "'(,none)'" }
    end

    reversible do |dir|
      dir.up do
        say_with_time "Populating ordering stats columns" do
          exec_update(<<~SQL)
          WITH stats AS (
          SELECT
            o.id AS ordering_id,
            stats.*
          FROM orderings o
          LEFT OUTER JOIN ordering_date_ranges d ON d.ordering_id = o.id
          LEFT OUTER JOIN ordering_entry_counts c ON c.ordering_id = o.id
          LEFT JOIN LATERAL (
            SELECT
            COALESCE(d.oldest_published, '(,none)'::public.variable_precision_date) AS oldest_published,
            COALESCE(d.latest_published, '(,none)'::public.variable_precision_date) AS latest_published,
            COALESCE(c.entries_count, 0) AS entries_count,
            COALESCE(c.visible_count, 0) AS visible_count
          ) stats ON true
        )
        UPDATE orderings AS o SET
          oldest_published = stats.oldest_published,
          latest_published = stats.latest_published,
          entries_count = stats.entries_count,
          visible_count = stats.visible_count
        FROM stats
        WHERE
          o.id = stats.ordering_id
          SQL
        end
      end
    end
  end
end

# frozen_string_literal: true

module Schemas
  module Orderings
    module Stats
      # An operation that calculates and updates stats for all orderings in the database,
      # selectively applying the updates only where there are changes.
      class CalculateAll
        include Dry::Monads[:result]
        include QueryOperation

        QUERY = <<~SQL
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
          AND
          (
            o.oldest_published <> stats.oldest_published
            OR
            o.latest_published <> stats.latest_published
            OR
            o.entries_count <> stats.entries_count
            OR
            o.visible_count <> stats.visible_count
          )
        SQL

        # @return [Dry::Monads::Success(Integer)]
        def call
          updated = sql_update!(QUERY)

          Success updated
        end
      end
    end
  end
end

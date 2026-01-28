# frozen_string_literal: true

module EntityVisibilities
  # An operation to check and update the `active` status of all {EntityVisibility} records.
  # It compares the current `active` status with the calculated value based on visibility and visibility range,
  # updating any records where there is a discrepancy.
  class Check
    include Dry::Monads[:result]
    include QueryOperation

    QUERY = <<~SQL
    WITH changes AS (
      SELECT
        ev.id AS id,
        stats.active AS active
      FROM entity_visibilities ev
      LEFT JOIN LATERAL (
        SELECT
        entity_visibility_active(ev.visibility, ev.visibility_range, CURRENT_TIMESTAMP) AS active
      ) stats ON true
      WHERE ev.active <> stats.active
    )
    UPDATE entity_visibilities AS ev SET
      active = changes.active
    FROM changes
    WHERE ev.id = changes.id
    SQL

    # @return [Dry::Monads::Success(Integer)]
    def call
      updated = sql_update!(QUERY)

      Success updated
    end
  end
end

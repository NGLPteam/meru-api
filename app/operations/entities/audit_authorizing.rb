# frozen_string_literal: true

module Entities
  # If a child entity is moved or deleted, it's not guaranteed to be removed
  # from the {AuthorizingEntity authorizing table} because we do not have
  # FK associations set up. It's not an immediate priority to remove rows
  # from this, so it runs in a scheduled task
  #
  # @see Entities::AuditAuthorizingJob
  class AuditAuthorizing
    include Dry::Monads[:result]
    include QueryOperation

    # Look for any authorizing entities that cannot be found in a calculated
    # set of _all_ authorizing entities. This performs acceptably well with
    # 250k rows extrapolated, but may need to be further refined with larger
    # entity sets.
    #
    # @note When we upgrade to PG 17, the `MERGE` function `WHEN NOT MATCHED BY SOURCE`
    #   should allow for a much more performant query.
    CLEANUP = <<~SQL.strip_heredoc.squish.freeze
    DELETE FROM authorizing_entities ae
    USING (
      WITH calculated AS (
        SELECT DISTINCT ON (ent.auth_path, subent.id, subent.scope, subent.hierarchical_type, subent.hierarchical_id)
        ent.auth_path AS auth_path,
        subent.id AS entity_id,
        subent.scope,
        subent.hierarchical_type,
        subent.hierarchical_id
        FROM entities ent
        INNER JOIN entities subent ON ent.auth_path @> subent.auth_path
      )
      SELECT
        auth_path, entity_id, scope, hierarchical_type, hierarchical_id
      FROM authorizing_entities
      LEFT OUTER JOIN calculated USING (auth_path, entity_id, scope, hierarchical_type, hierarchical_id)
      WHERE calculated.auth_path IS NULL
    ) oddities
    WHERE
      oddities.auth_path = ae.auth_path
      AND
      oddities.entity_id = ae.entity_id
      AND
      oddities.scope = ae.scope
      AND
      oddities.hierarchical_type = ae.hierarchical_type
      AND
      oddities.hierarchical_id = ae.hierarchical_id
    ;
    SQL

    # @return [Dry::Monads::Success(Integer)]
    def call
      Success sql_delete! CLEANUP
    end
  end
end

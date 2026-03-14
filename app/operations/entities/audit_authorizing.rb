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

    # Remove any authorizing entities that cannot be found in a calculated
    # set of _all_ authorizing entities.
    CLEANUP = <<~SQL
    MERGE INTO authorizing_entities ae
    USING (
      SELECT DISTINCT ON (ent.auth_path, subent.id, subent.scope, subent.hierarchical_type, subent.hierarchical_id)
        ent.auth_path AS auth_path,
        subent.id AS entity_id,
        subent.scope,
        subent.hierarchical_type,
        subent.hierarchical_id
      FROM entities ent
      INNER JOIN entities subent ON ent.auth_path @> subent.auth_path
    ) calculated
    ON ae.auth_path = calculated.auth_path
      AND ae.entity_id = calculated.entity_id
      AND ae.scope = calculated.scope
      AND ae.hierarchical_type = calculated.hierarchical_type
      AND ae.hierarchical_id = calculated.hierarchical_id
    WHEN NOT MATCHED BY SOURCE THEN
      DELETE
    ;
    SQL

    # @return [Dry::Monads::Success(void)]
    def call
      sql_insert! CLEANUP

      Success()
    end
  end
end

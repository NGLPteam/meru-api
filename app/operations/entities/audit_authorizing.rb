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
    MERGE INTO authorizing_entities target
    USING (
      SELECT DISTINCT ON (ent.auth_path, subent.id, subent.scope, subent.hierarchical_type, subent.hierarchical_id)
        ent.auth_path AS auth_path,
        subent.id AS entity_id,
        subent.scope,
        subent.hierarchical_type,
        subent.hierarchical_id
        FROM entities ent
        INNER JOIN entity_hierarchies eh ON eh.ancestor_type = ent.entity_type AND eh.ancestor_id = ent.entity_id
        INNER JOIN entities subent ON subent.entity_type = eh.descendant_type AND subent.entity_id = eh.descendant_id
    ) source
    ON target.auth_path = source.auth_path
      AND target.entity_id = source.entity_id
      AND target.scope = source.scope
      AND target.hierarchical_type = source.hierarchical_type
      AND target.hierarchical_id = source.hierarchical_id
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

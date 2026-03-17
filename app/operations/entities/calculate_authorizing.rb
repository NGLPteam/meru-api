# frozen_string_literal: true

module Entities
  # Calculate the requisite {AuthorizingEntity} rows for a specific `auth_path` (via {Entity}),
  # system-wide when passed `auth_path: nil`.
  #
  # If an {Entity} is deleted, all rows associated with that specific entity and its children
  # will be removed. When an entity is reparented, any lingering authorizing entities will be
  # removed by the `MERGE` query's `WHEN NOT MATCHED BY SOURCE` clause.
  #
  # {Entities::AuditAuthorizing} runs on an interval to ensure that any discrepancies between
  # the {Entity} and {AuthorizingEntity} tables are cleaned up, but may be retired soon if
  # `MERGE` continues to keep things consistent.
  class CalculateAuthorizing
    include Dry::Monads[:do, :result]
    include QueryOperation

    # Insert all child entities for a given `auth_path` in {Entity the entity table}
    # as well as a hierarchical reference to said entity.
    PREFIX = <<~SQL
    WITH calculated AS (
      SELECT DISTINCT ON (ent.auth_path, subent.id, subent.scope, subent.hierarchical_type, subent.hierarchical_id)
        ent.auth_path AS auth_path,
        subent.id AS entity_id,
        subent.scope,
        subent.hierarchical_type,
        subent.hierarchical_id
        FROM entities ent
        INNER JOIN entity_hierarchies eh ON eh.ancestor_type = ent.entity_type AND eh.ancestor_id = ent.entity_id
        INNER JOIN entities subent ON subent.entity_type = eh.descendant_type AND subent.entity_id = eh.descendant_id
    SQL

    # If a row already exists, ignore it. {AuthorizingEntity} has no
    # updatable columns.
    SUFFIX = <<~SQL
    )
    MERGE INTO authorizing_entities AS target
    USING calculated AS source
        ON target.auth_path = source.auth_path
        AND target.entity_id = source.entity_id
        AND target.scope = source.scope
        AND target.hierarchical_type = source.hierarchical_type
        AND target.hierarchical_id = source.hierarchical_id
      WHEN MATCHED THEN DO NOTHING
    WHEN NOT MATCHED BY TARGET THEN
      INSERT (auth_path, entity_id, scope, hierarchical_type, hierarchical_id)
      VALUES (source.auth_path, source.entity_id, source.scope, source.hierarchical_type, source.hierarchical_id)
    WHEN NOT MATCHED BY SOURCE
    SQL

    # @param [String, nil] auth_path the ltree representing the path of the entity in the context of the hierarchy
    # @return [Dry::Monads::Success(Integer)]
    def call(auth_path: nil)
      query = [PREFIX, generate_infix_for(auth_path:), SUFFIX, generate_delete_suffix_for(auth_path:)]

      query << <<~SQL
      THEN DELETE
      SQL

      sql = compile_query(*query)

      inserted = sql_insert!(sql)

      Success(inserted)
    end

    private

    # Generate an infix to possibly fit between {PREFIX} and {SUFFIX}.
    #
    # @param [String] auth_path
    # @return [String]
    def generate_infix_for(auth_path: nil)
      if auth_path.present?
        with_sql_template(<<~SQL, path: connection.quote(auth_path))
        WHERE ent.auth_path @> %<path>s OR ent.auth_path <@ %<path>s
        SQL
      else
        ""
      end
    end

    # Generate a condition suffix for the `WHEN NOT MATCHED BY SOURCE` clause.
    #
    # @param [String] auth_path
    # @return [String]
    def generate_delete_suffix_for(auth_path: nil)
      if auth_path.present?
        with_sql_template(<<~SQL, path: connection.quote(auth_path))
        AND (target.auth_path @> %<path>s OR target.auth_path <@ %<path>s)
        SQL
      else
        ""
      end
    end
  end
end

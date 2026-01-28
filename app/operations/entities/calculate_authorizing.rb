# frozen_string_literal: true

module Entities
  # Calculate the requisite {AuthorizingEntity} rows for a specific `auth_path` (via {Entity}),
  # based on Entity staleness, or system-wide when passed `auth_path: nil, stale: false`.
  #
  # If an {Entity} is deleted, all rows associated with that specific entity and its children
  # will be removed. However, if a child entity is reparented, it will instead need to be pruned
  # by {Entities::AuditAuthorizing} at a later interval.
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
        INNER JOIN entities subent ON ent.auth_path @> subent.auth_path
    SQL

    # If a row already exists, ignore it. {AuthorizingEntity} has no
    # updatable columns.
    SUFFIX = <<~SQL
    )
    INSERT INTO authorizing_entities
    (auth_path, entity_id, scope, hierarchical_type, hierarchical_id)
    SELECT auth_path, entity_id, scope, hierarchical_type, hierarchical_id
    FROM calculated
    LEFT OUTER JOIN authorizing_entities ae USING (auth_path, entity_id, scope, hierarchical_type, hierarchical_id)
    WHERE ae.auth_path IS NULL
    ON CONFLICT (auth_path, entity_id, scope, hierarchical_type, hierarchical_id) DO NOTHING;
    SQL

    # @param [String, nil] auth_path
    # @param [HierarchicalEntity] source
    # @param [Boolean] stale
    # @return [Dry::Monads::Success(Integer)]
    def call(auth_path: nil, source: nil, stale: false)
      query = [PREFIX, generate_infix_for(auth_path:, source:, stale:), SUFFIX]

      inserted = sql_insert!(*query)

      Success(inserted)
    end

    private

    # Generate an infix to possibly fit between {PREFIX} and {SUFFIX}.
    #
    # @param [String] auth_path
    # @param [HierarchicalEntity] source
    # @param [Boolean] stale
    # @return [String]
    def generate_infix_for(auth_path: nil, source: nil, stale: false)
      if auth_path.present?
        with_sql_template(<<~SQL.squish, path: connection.quote(auth_path))
        WHERE ent.auth_path @> %<path>s OR ent.auth_path <@ %<path>s
        SQL
      elsif source.present?
        with_sql_template(<<~SQL.squish, entity_id: connection.quote(source.id_for_entity), entity_type: connection.quote(source.entity_type))
        WHERE ent.entity_id = %<entity_id>s AND ent.entity_type = %<entity_type>s
        SQL
      elsif stale
        with_sql_template <<~SQL
        WHERE ent.stale
        SQL
      else
        ""
      end
    end
  end
end

# frozen_string_literal: true

module Access
  class CalculateGrantedPermissions
    include Dry::Monads[:do, :result]
    include QueryOperation

    PREFIX = <<~SQL
    WITH calculated_grants AS (
      SELECT ag.id AS access_grant_id,
        p.id AS permission_id,
        ag.user_id AS user_id,
        x.scope,
        p.path AS action,

        ag.role_id AS role_id,
        ag.accessible_type AS accessible_type,
        ag.accessible_id AS accessible_id,

        ag.auth_path,
        rp.inferred AS inferred,

        ag.created_at,
        ag.updated_at
      FROM access_grants ag
      INNER JOIN role_permissions rp USING (role_id)
      INNER JOIN permissions p ON p.id = rp.permission_id
      LEFT JOIN LATERAL (
        SELECT DISTINCT t.scope FROM unnest(p.inheritance) AS t(scope)
      ) x ON true
    SQL

    SUFFIX = <<~SQL
    )
    MERGE INTO granted_permissions AS target
    USING calculated_grants AS source
      ON target.access_grant_id = source.access_grant_id
      AND target.permission_id = source.permission_id
      AND target.user_id = source.user_id
      AND target.scope = source.scope
      AND target.action = source.action
    WHEN MATCHED AND (
      target.role_id <> source.role_id
      OR target.accessible_type <> source.accessible_type
      OR target.accessible_id <> source.accessible_id
      OR target.auth_path <> source.auth_path
      OR target.inferred <> source.inferred
    ) THEN UPDATE SET
      role_id = source.role_id,
      accessible_type = source.accessible_type,
      accessible_id = source.accessible_id,
      auth_path = source.auth_path,
      inferred = source.inferred,
      updated_at = source.updated_at
    WHEN NOT MATCHED THEN INSERT
      (access_grant_id, permission_id, user_id, scope, action, role_id, accessible_type, accessible_id, auth_path, inferred, created_at, updated_at)
    VALUES
      (source.access_grant_id, source.permission_id, source.user_id, source.scope, source.action, source.role_id, source.accessible_type, source.accessible_id, source.auth_path, source.inferred, source.created_at, source.updated_at)
    WHEN NOT MATCHED BY SOURCE
    SQL

    DELETE_SUFFIX = <<~SQL
    THEN DELETE
    SQL

    # @param [AccessGrant, nil] access_grant
    # @param [Role, nil] role
    # @return [Dry::Monads::Success(void)]
    def call(access_grant: nil, role: nil)
      sql_insert!(
        PREFIX,
        generate_infix_for(access_grant:, role:),
        SUFFIX,
        generate_delete_infix_for(access_grant:, role:),
        DELETE_SUFFIX
      )

      Success()
    end

    private

    # @param [AccessGrant, nil] access_grant
    # @param [Role, nil] role
    # @return [String]
    def generate_infix_for(access_grant: nil, role: nil)
      ag_id = with_quoted_id_for(access_grant, <<~SQL)
      ag.id = %s
      SQL

      role_id = with_quoted_id_for(role, <<~SQL)
      ag.role_id = %s
      SQL

      conditions = compile_and(ag_id, role_id)

      return "" if conditions.blank?

      with_sql_template(<<~SQL, conditions)
      WHERE %s
      SQL
    end

    # @param [AccessGrant, nil] access_grant
    # @param [Role, nil] role
    # @return [String]
    def generate_delete_infix_for(access_grant: nil, role: nil)
      ag_id = with_quoted_id_for(access_grant, <<~SQL)
      target.access_grant_id = %s
      SQL

      role_id = with_quoted_id_for(role, <<~SQL)
      target.role_id = %s
      SQL

      conditions = compile_and(ag_id, role_id)

      return "" if conditions.blank?

      with_sql_template(<<~SQL, conditions)
      AND %s
      SQL
    end
  end
end

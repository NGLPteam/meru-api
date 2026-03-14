# frozen_string_literal: true

module Roles
  class CalculateRolePermissions
    include Dry::Monads[:result]
    include QueryOperation

    PREFIX = <<~SQL
    INSERT INTO role_permissions (permission_id, role_id, action, inferring_actions, inferring_scopes, inferred, updated_at)
    SELECT ip.id AS permission_id, r.id AS role_id, ip.path AS action,
      COALESCE(array_agg(DISTINCT p.path) FILTER (WHERE p.path <> ip.path), '{}') AS inferring_actions,
      COALESCE(array_accum_distinct(ARRAY[p.head, p.scope]) FILTER (WHERE p.path <> ip.path), '{}') AS inferring_scopes,
      ip.path ~ 'self.*' AND NOT bool_and(r.allowed_actions @> ip.path) AS inferred,
      MAX(GREATEST(r.updated_at, p.updated_at)) AS updated_at
    FROM roles r
    LEFT JOIN LATERAL (
      SELECT path FROM unnest(r.allowed_actions) AS x(path)
    ) actions ON true
    INNER JOIN permissions p USING (path)
    INNER JOIN permissions ip ON p.kind = ip.kind AND p.suffix = ip.suffix AND ip.head IN (p.head, 'self')
    SQL

    SUFFIX = <<~SQL
    GROUP BY 1,2,3
    ON CONFLICT (role_id, permission_id) DO UPDATE SET
      action = EXCLUDED.action,
      inferring_actions = EXCLUDED.inferring_actions,
      inferring_scopes = EXCLUDED.inferring_scopes,
      inferred = EXCLUDED.inferred,
      updated_at = EXCLUDED.updated_at
    SQL

    CLEANUP = <<~SQL
    DELETE FROM role_permissions rp
    USING roles r
    WHERE
      r.id = rp.role_id
      AND NOT r.allowed_actions @> rp.action
      AND NOT rp.inferred
    SQL

    def call(role: nil)
      inserted = sql_insert! PREFIX, generate_infix_for(role), SUFFIX

      deleted = sql_delete! CLEANUP

      if role.present?
        Access::CalculateRoleGrantedPermissionsJob.perform_later role
      else
        Access::CalculateAllGrantedPermissionsJob.perform_later
      end

      Success(inserted:, deleted:)
    end

    private

    def generate_infix_for(role)
      with_quoted_id_for(role, <<~SQL.squish)
      WHERE r.id = %s
      SQL
    end
  end
end

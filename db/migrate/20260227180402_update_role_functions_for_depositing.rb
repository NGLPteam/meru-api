# frozen_string_literal: true

class UpdateRoleFunctionsForDepositing < ActiveRecord::Migration[7.2]
  def up
    execute <<~SQL
    CREATE OR REPLACE FUNCTION public.calculate_role_priority(public.role_identifier) RETURNS int AS $$
    SELECT CASE $1
    WHEN 'admin' THEN 40000
    WHEN 'manager' THEN 20000
    WHEN 'editor' THEN -20000
    WHEN 'reviewer' THEN -30000
    WHEN 'depositor' THEN -35000
    WHEN 'reader' THEN -40000
    END;
    $$ LANGUAGE SQL IMMUTABLE PARALLEL SAFE;
    SQL

    exec_update <<~SQL
    WITH new_roles AS (
      SELECT 'depositor'::role_identifier AS identifier, 'Depositor' AS name,
      jsonb_build_object(
        'self', jsonb_build_object(
          'read', true,
          'deposit', true,
          'assets', jsonb_build_object('read', true)
        ),
        'collections', jsonb_build_object(
          'read', true,
          'deposit', true,
          'assets', jsonb_build_object('read', true)
        ),
        'items', jsonb_build_object(
          'read', true,
          'deposit', true,
          'assets', jsonb_build_object('read', true)
        )
      ) AS access_control_list,
      jsonb_build_object(
        'admin', jsonb_build_object('access', true),
        'contributors', jsonb_build_object('read', true),
        'roles', jsonb_build_object('read', true)
      ) AS global_access_control_list
      UNION ALL
      SELECT 'reviewer'::role_identifier AS identifier, 'Reviewer' AS name,
      jsonb_build_object(
        'self', jsonb_build_object(
          'read', true,
          'review', true,
          'assets', jsonb_build_object('read', true)
        ),
        'collections', jsonb_build_object(
          'read', true,
          'review', true,
          'assets', jsonb_build_object('read', true)
        ),
        'items', jsonb_build_object(
          'read', true,
          'review', true,
          'assets', jsonb_build_object('read', true)
        )
      ) AS access_control_list,
      jsonb_build_object(
        'admin', jsonb_build_object('access', true),
        'contributors', jsonb_build_object('read', true),
        'roles', jsonb_build_object('read', true)
      ) AS global_access_control_list
    )
    INSERT INTO roles (identifier, name, access_control_list, global_access_control_list)
    SELECT identifier, name, access_control_list, global_access_control_list FROM new_roles
    ON CONFLICT (identifier) DO UPDATE SET name = EXCLUDED.name,
      access_control_list = EXCLUDED.access_control_list,
      global_access_control_list = EXCLUDED.global_access_control_list;
    SQL
  end

  def down
    # Intentionally left blank, this cannot be reversed.
  end
end

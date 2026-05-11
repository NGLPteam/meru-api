# frozen_string_literal: true

class UpdateRolesForAuthor < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
    CREATE OR REPLACE FUNCTION public.calculate_role_priority(public.role_identifier) RETURNS int AS $$
    SELECT CASE $1
    WHEN 'admin' THEN 40000
    WHEN 'manager' THEN 20000
    WHEN 'editor' THEN -20000
    WHEN 'reviewer' THEN -30000
    WHEN 'depositor' THEN -35000
    WHEN 'author' THEN -37500
    WHEN 'reader' THEN -40000
    END;
    $$ LANGUAGE SQL IMMUTABLE PARALLEL SAFE;
    SQL
  end

  def down
    # Intentionally left blank
  end
end

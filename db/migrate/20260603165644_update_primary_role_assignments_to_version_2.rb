class UpdatePrimaryRoleAssignmentsToVersion2 < ActiveRecord::Migration[8.1]
  def change
    update_view :primary_role_assignments, version: 2, revert_to_version: 1
  end
end

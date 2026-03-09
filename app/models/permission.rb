# frozen_string_literal: true

# Permission records are not created or queried directly by the API, but instead inform the structure of
# WDP's permissions in a maintainable way. Specifically, they are used when calculating {GrantedPermission},
# {RolePermission}, {ContextualPermission}, {ContextualSinglePermission}, and so on.
#
# @see Permissions::Sync
class Permission < ApplicationRecord
  include GenericAccessible
  include TimestampScopes

  pg_enum! :kind, as: "permission_kind"

  has_many :role_permissions, dependent: :destroy, inverse_of: :permission
  has_many :roles, through: :role_permissions

  scope :for_path, ->(path_or_paths) { where(path: path_or_paths) }

  class << self
    def ids_for(*actions)
      actions.flatten!

      for_path(actions).ids
    end

    # @return [ActiveRecord::Relation<Permission>]
    def matching(*patterns)
      patterns.flatten!

      where arel_ltree_matches_one_or_any(arel_table[:path], patterns)
    end
  end
end

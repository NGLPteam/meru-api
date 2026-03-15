# frozen_string_literal: true

# This is a view used to check whether a {User} has a specific {Permission} on an {Entity}.
#
# When querying, some combination of the above three should be provided. `ContextualSinglePermission.all` should be avoided,
# as it is a very expensive query.
#
# To view a collection of all permissions that a user can perform on an entity, see {ContextualPermission}.
class ContextualSinglePermission < ApplicationRecord
  include ScopesForHierarchical
  include ScopesForUser
  include SkipsPreloading
  include View

  self.primary_key = [:user_id, :hierarchical_type, :hierarchical_id, :permission_id]

  belongs_to :access_grant
  belongs_to :hierarchical, polymorphic: true
  belongs_to :permission
  belongs_to :role
  belongs_to :user

  scope :for_path, ->(path_or_paths) { where(permission_id: Permission.for_path(path_or_paths).select(:id)) }

  class << self
    # @param [User] user
    # @param [HierarchicalEntity] hierarchical
    def manages_access_for?(user, hierarchical)
      with_permitted_actions_for(user, "self.manage_access").exists?(hierarchical:)
    end

    # @param [<String>] actions
    # @return [ActiveRecord::Relation<ContextualPermission>]
    def with_actions(*actions)
      actions.flatten!

      actions.present? ? for_path(actions.flatten) : all
    end

    # @param [AnonymousUser, User] user
    # @param [<String>] actions
    # @return [ActiveRecord::Relation<ContextualPermission>]
    def with_permitted_actions_for(user, *actions)
      for_user(user).with_actions(*actions)
    end
  end
end

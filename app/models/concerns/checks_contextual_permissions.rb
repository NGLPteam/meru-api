# frozen_string_literal: true

# Scopes and other helpers for checking on permissions for a {HierarchicalEntity},
# {Entity}, or {EntityAdjacent}.
#
# @see ContextualSinglePermission
module ChecksContextualPermissions
  extend ActiveSupport::Concern

  included do
    extend Dry::Core::ClassAttributes

    defines :contextual_permission_primary_key, type: Entities::Types::Symbol

    contextual_permission_primary_key :_must_be_set
  end

  module ClassMethods
    # @see .with_permitted_actions_for
    # @see Resolvers::FiltersByEntityPermission#apply_access_with_read_only
    # @note This is specifically for checking for permissions to read the entire entity,
    #   not necessarily whether or not the entity can be shown in the FE, etc.
    # @param [User] user
    # @return [ActiveRecord::Relation<HierarchicalEntity>]
    def readable_by(user)
      return all if user.try(:has_global_admin_access?)

      with_permitted_actions_for(user, "self.read")
    end

    # @see .with_permitted_actions_for
    # @see Resolvers::FiltersByEntityPermission#apply_access_with_update
    # @param [User] user
    # @return [ActiveRecord::Relation<HierarchicalEntity>]
    def updatable_by(user)
      return all if user.try(:has_global_admin_access?)

      with_permitted_actions_for(user, "self.update")
    end

    # @param [User, AnonymousUser] user
    # @return [ActiveRecord::Relation<HierarchicalEntity>]
    def visible_to(user)
      return currently_visible if user.blank? || user.anonymous? || user.new_record?
      return all if user.has_global_admin_access?

      left_outer_joins(:entity_visibility).where(arel_visible_to(user))
    end

    # @param [User] user
    # @param [<String>] actions
    # @return [ActiveRecord::Relation<HierarchicalEntity>]
    def with_permitted_actions_for(user, *actions)
      constraint = ContextualSinglePermission.with_permitted_actions_for(user, *actions).select(:hierarchical_id)

      where(contextual_permission_primary_key => constraint)
    end

    private

    # @param [User] user
    # @return [Arel::Nodes::Case]
    def arel_visible_to(user)
      cppk = arel_table[contextual_permission_primary_key]

      permission_constraint = ContextualSinglePermission.with_permitted_actions_for(user, "self.read").select(:hierarchical_id)

      has_read_permission = arel_expr_in_query(cppk, permission_constraint)

      condition = has_read_permission

      if all.model == ::Entity
        is_community = arel_table[:hierarchical_type].eq("Community")

        condition = arel_grouped(is_community.or(has_read_permission))
      end

      arel_case(EntityVisibility.arel_table[:active]) do |stmt|
        stmt.when(true).then(true)
        stmt.else(condition)
      end
    end
  end
end

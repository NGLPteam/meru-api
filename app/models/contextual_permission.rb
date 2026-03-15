# frozen_string_literal: true

# Similar to {ContextualSinglePermission}, this view is used to calculate what {Permission}s,
# if any, a {User} can perform on an {Entity}. It is highly optimized for selective querying
# and should not be called to fetch every possible user/entity/permission combination.
class ContextualPermission < ApplicationRecord
  include ScopesForHierarchical
  include ScopesForUser
  include SkipsPreloading
  include TimestampScopes
  include View

  DEFAULT_ATTRIBUTES = {
    has_any_role: false,
    has_direct_role: false,
    access_grant_ids: [],
    role_ids: [],
    allowed_actions: [],
    access_control_list: {},
    grid: {}
  }.freeze

  self.primary_key = [:user_id, :hierarchical_type, :hierarchical_id]

  attribute :access_control_list, Roles::AccessControlList.to_type, default: -> { {} }
  attribute :grid, Roles::EntityPermissionGrid.to_type, default: -> { {} }

  belongs_to :hierarchical, polymorphic: true
  belongs_to :user, inverse_of: :contextual_permissions

  has_many_readonly :contextually_assignable_roles, -> { in_order }, primary_key:, foreign_key: primary_key, inverse_of: :contextual_permission
  has_many_readonly :contextually_assigned_access_grants, primary_key:, foreign_key: primary_key, inverse_of: :contextual_permission
  has_many_readonly :contextually_assigned_roles, primary_key:, foreign_key: primary_key, inverse_of: :contextual_permission

  has_many :assignable_roles, through: :contextually_assignable_roles, source: :role

  has_many :access_grants, -> { distinct }, through: :contextually_assigned_access_grants
  has_many :roles, -> { distinct }, through: :contextually_assigned_roles

  scope :with_associations, -> { preload(:assignable_roles, :roles) }

  delegate :permissions, to: :access_control_list

  class << self
    # If a match cannot be found for the provided combination,
    # {#empty_permission_for an empty result} will be provided.
    #
    # @param [User] user
    # @param [HierarchicalEntity, ActiveRecord::Relation<HierarchicalEntity>] entity
    # @return [ContextualPermission]
    def fetch(user, entity)
      if entity.kind_of?(HierarchicalEntity)
        scope_to(user, entity).first || empty_permission_for(user, entity)
      else
        empty_permission_for(user, entity)
      end
    end

    # @param [User, AnonymousUser, ActiveRecord::Relation<User>] user
    # @param [HierarchicalEntity, <HierarchicalEntity>] entity
    # @return [ActiveRecord::Relation<ContextualPermission>]
    def scope_to(user, entity)
      return none if user.kind_of?(AnonymousUser)

      for_user(user).for_hierarchical(entity).with_associations
    end

    def sample(n = nil, base_users: User.all, base_entities: Entity.all)
      Retryable.retryable(tries: 10, on: ActiveRecord::RecordNotFound, sleep: 0) do
        actual_n = n.to_i.clamp(1..20)

        users = base_users.where(id: AccessGrant.select(:subject_id)).scoped_sample(actual_n)

        entities = base_entities.readable_by(users).sample_entities(actual_n)

        query = scope_to users, entities

        actual_n == 1 ? query.first! : query.take(actual_n)
      end
    end

    # Calculate an empty permission set for a given user / entity combination.
    #
    # @param [User] user
    # @param [HierarchicalEntity, ActiveRecord::Relation<HierarchicalEntity>] entity
    # @return [ContextualPermission]
    def empty_permission_for(user, entity)
      attrs = DEFAULT_ATTRIBUTES.dup

      attrs[:hierarchical] = entity if entity.kind_of?(HierarchicalEntity)
      attrs[:user] = user if user.kind_of?(User)

      ContextualPermission.new(attrs)
    end

    # @param [<String>] actions
    # @return [ActiveRecord::Relation<ContextualPermission>]
    def with_actions(*actions)
      actions.flatten!

      allowed_actions = arel_table[:allowed_actions]

      return none if actions.blank?

      expr = arel_or_expressions(actions) do |action|
        arel_ltree_contains(allowed_actions, arel_ltree(action))
      end

      where expr
    end

    # @param [AnonymousUser, User] user
    # @param [<String>] actions
    # @return [ActiveRecord::Relation<ContextualPermission>]
    def with_permitted_actions_for(user, *actions)
      for_user(user).with_actions(*actions)
    end
  end
end

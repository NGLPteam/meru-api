# frozen_string_literal: true

class AccessGrant < ApplicationRecord
  include AssignsPolymorphicForeignKey
  include ScopesForUser
  include TimestampScopes

  belongs_to :accessible, polymorphic: true
  belongs_to :subject, polymorphic: true

  belongs_to :role, inverse_of: :access_grants

  belongs_to :community, optional: true
  belongs_to :collection, optional: true
  belongs_to :item, optional: true

  belongs_to :user_group, optional: true
  belongs_to :user, optional: true

  has_many :grouped_users, through: :user_group, source: :users
  has_many :permissions, through: :role

  has_many_readonly :management_links, class_name: "AccessGrantManagementLink", inverse_of: :access_grant

  has_many_readonly :contextually_assigned_access_grants, inverse_of: :access_grant

  has_many :managers, -> { distinct }, through: :management_links, source: :user

  scope :for_system_role, ->(identifier) { where(role: Role.for_identifier(identifier)) }
  scope :for_accessible_type, ->(type) { where(accessible_type: type) }
  scope :for_subject, ->(subject) { where(subject:) }
  scope :for_subject_type, ->(type) { where(subject_type: type) }
  scope :for_possible_subject, ->(subject) { for_subject(subject) if subject.present? }

  scope :for_communities, -> { for_accessible_type("Community") }
  scope :for_collections, -> { for_accessible_type("Collection") }
  scope :for_items, -> { for_accessible_type("Item") }

  scope :for_role, ->(role) { where(role:) }
  scope :for_role_name, ->(name) { joins(:role).merge(Role.for_name(name)) }

  scope :for_groups, -> { for_subject_type "UserGroup" }
  scope :for_users, -> { for_subject_type "User" }

  scope :managed_by, ->(user) { where(id: AccessGrantManagementLink.for_user(user).select(:access_grant_id)) }

  scope :with_preloads, -> { preload(:accessible, :subject, :role, :user, :user_group, :community, :collection, :item) }

  scope :admin, -> { for_system_role :admin }

  scope :to_global_admins, -> { for_users.where(subject_id: User.global_admins.select(:id)) }
  scope :to_non_global_admins, -> { for_users.where.not(subject_id: User.global_admins.select(:id)) }

  scope :invalid_admin_assignments, -> { admin.to_non_global_admins }

  assign_polymorphic_foreign_key! :accessible, :community, :collection, :item
  assign_polymorphic_foreign_key! :subject, :user, :user_group

  before_validation :sync_auth_path!

  after_save_commit :calculate_granted_permissions!

  def has_manager?(user)
    case user
    in ::User
      has_manager?(user.id)
    in ::Support::GlobalTypes::UUID
      calculate_manager?(user)
    else
      # :nocov:
      false
      # :nocov:
    end
  end

  # @api private
  # @return [void]
  def sync_auth_path!
    self.auth_path = accessible.try(:auth_path)
  end

  # @api private
  # @return [void]
  def calculate_granted_permissions!
    MeruAPI::Container["access.calculate_granted_permissions"].call(access_grant: self)
  end

  # @return [Class]
  def graphql_node_type
    "Types::#{subject_type}#{accessible_type}AccessGrantType".constantize
  end

  # @return [Hash]
  def unique_tuple
    {
      accessible_type:,
      accessible_id:,
      role_id:,
      subject_type:,
      subject_id:,
    }
  end

  private

  # @return [AccessGrant, nil]
  def existing_record
    return self if persisted?

    self.class.find_by(unique_tuple)
  end

  # @param [String] user_id
  def calculate_manager?(user_id)
    return managers.exists?(user_id) if persisted?

    existing_record.try(:has_manager?, user_id) || ContextualSinglePermission.manages_access_for?(user_id, accessible)
  end

  class << self
    def for_user_group(user_group)
      user_group.present? ? where(user_group:) : none
    end

    # @param [Role] role
    # @param [HierarchicalEntity] on
    # @param [AccessGrantSubject] to
    def has_granted?(role, on:, to:)
      exists?(role:, accessible: on, subject: to)
    end

    # @param [HierarchicalEntity] accessible
    # @param [AccessGrantSubject] subject
    def fetch(accessible, subject)
      where(accessible:, subject:).first_or_initialize
    end

    # @param [User] user
    # @return [ActiveRecord::Relation<AccessGrant>]
    def manageable_by(user)
      if user.has_global_admin_access?
        all
      elsif user.anonymous?
        none
      else
        managed_by user
      end
    end

    # @return [ActiveRecord::Relation<AccessGrant>]
    def matching_permissions(*patterns)
      inner_scope = unscoped.joins(:permissions).merge(Permission.contextual.matching(*patterns))

      where(id: inner_scope.select(:id))
    end

    # Uses an `ltree @> ltree` operation to check if the entity is contained by this access grant.
    #
    # @param [HierarchicalEntity, #auth_path] entity
    # @return [Arel::Nodes::InfixOperator]
    def arel_contains_entity(entity)
      arel_ltree_contains(arel_table[:auth_path], arel_cast(entity.auth_path, "ltree"))
    end

    # @return [ActiveRecord::Relation<AccessGrant>]
    def with_allowed_action(name:, entity:)
      joins(:role).where(arel_contains_entity(entity)).where(Role.arel_allowed_action(name))
    end

    def with_allowed_action?(**options)
      with_allowed_action(**options).exists?
    end

    # @return [ActiveRecord::Relation<AccessGrant>]
    def with_asset_creation
      matching_permissions "*.assets.create"
    end

    def with_asset_creation?
      with_asset_creation.exists?
    end
  end
end

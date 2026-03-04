# frozen_string_literal: true

# The base policy for authorizing actions in the application.
#
# @abstract
class ApplicationPolicy
  extend Dry::Core::ClassAttributes
  include PolicyReadability

  # @return [ApplicationRecord]
  attr_reader :record

  # @return [User, AnonymousUser]
  attr_reader :user

  # @param [User, AnonymousUser] user
  # @param [ApplicationRecord] record
  def initialize(user, record)
    @user = user || AnonymousUser.new
    @record = record
  end

  # This permission determines whether a given {#user}
  # has been granted read-access to the {#record}.
  #
  # Specifically, it means the user can read a fuller representation
  # of the record, as opposed to simply being able to {#show? view it}
  # in the frontend.
  #
  # @abstract
  # @see #show?
  def read? = always_readable? || readable_in_dev? || admin_or_owns_resource?

  # Sometimes we need to allow read access specifically for use with mutation arguments
  # in a way that differs from normal read access. This happens in other projects, but
  # not here yet. This is here for support with {Types::AbstractModel.authorized?}.
  #
  # For the sake of mutations, assume arguments provided can always be read and worry
  # about authorizing within the context of the mutation.
  def read_for_mutation? = true

  # Whether the user can see a list of the provided records
  def index? = always_readable? || show?

  # This determines whether an individual record can
  # appear to a given {#user}.
  #
  # @abstract
  # @see #read?
  def show? = always_readable? || read?

  # Whether the user can create a new instance of the record type.
  # @note False by default.
  # @abstract
  def create? = false

  def update? = admin_or_owns_resource?

  def destroy? = admin_or_owns_resource?

  def manage_access? = has_admin?

  # @!group Hierarchical Permissions

  # @abstract
  def create_assets? = false

  # @abstract
  def create_collections? = false

  # @abstract
  def create_items? = false

  # @!endgroup Hierarchical Permissions

  # @!group Auth Helpers

  def admin_or_owns_resource?
    return false if user.anonymous?

    return true if user.has_global_admin_access?

    # :nocov:
    if record.kind_of?(User)
      user == record
    elsif record.respond_to?(:user_id)
      record.user_id == user.id
    elsif record.respond_to?(:user)
      record.user == user
    else
      false
    end
    # :nocov:
  end

  def has_any_access_management_permissions?
    user.can_manage_access_globally? || user.can_manage_access_contextually?
  end

  # Whether the user has global admin access
  def has_admin? = user.has_global_admin_access?

  # @param [String] action_name
  # @return [Boolean] whether the user has been granted the specified action
  def has_allowed_action?(action_name) = action_name.to_s.in?(user.allowed_actions)

  # Whether the user has been granted the specified action, or is a global admin
  # @param [String] action_name
  def has_admin_or_allowed_action?(action_name) = has_admin? || has_allowed_action?(action_name)

  # @!endgroup Auth Helpers

  # @param [ApplicationRecord] record
  # @param [Symbol] query
  # @param [Boolean] admin_always_allowed
  # @param [User, AnonymousUser] pundit_user
  def authorized?(record, query, admin_always_allowed: true, pundit_user: @user)
    # :nocov:
    return true if admin_always_allowed && pundit_user.has_global_admin_access?

    return false if record.blank?

    policy_for(record, pundit_user:).public_send query
    # :nocov:
  end

  # Load a sub-policy.
  #
  # @param [ApplicationRecord] record
  # @param [User, AnonymousUser] pundit_user
  # @return [ApplicationPolicy]
  def policy_for(record, pundit_user: @user)
    subpolicies[[record, pundit_user]] ||= Pundit.policy! pundit_user, record
  end

  private

  # @!attribute [r] subpolicies
  # @return [{ (ApplicationRecord, User) => ApplicationPolicy }]
  def subpolicies
    @subpolicies ||= {}
  end

  # @abstract
  class Scope
    # @return [ActiveRecord::Relation]
    attr_reader :scope

    # @return [AnonymousUser, User]
    attr_reader :user

    delegate :anonymous?, :has_global_admin_access?, :has_allowed_action?, to: :user

    # @param [User, AnonymousUser] user
    # @param [ActiveRecord::Relation] scope
    def initialize(user, scope)
      @user = user || AnonymousUser.new
      @scope = scope
    end

    # @abstract
    # @return [ActiveRecord::Relation]
    def resolve
      # :nocov:
      return scope.none if anonymous?

      scope.all
      # :nocov:
    end

    # @see #has_global_admin_access?
    # @see #has_allowed_action?
    # @param [String] name
    def admin_or_has_allowed_action?(name)
      has_global_admin_access? || has_allowed_action?(name)
    end
  end
end

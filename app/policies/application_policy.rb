# frozen_string_literal: true

# The base policy for authorizing actions in the application.
#
# @abstract
class ApplicationPolicy < ActionPolicy::Base
  extend Dry::Core::ClassAttributes

  defines :always_readable, :readable_in_dev, type: Roles::Types::Bool

  # @!attribute [r] always_readable
  #   @!scope class
  #   Whether the record is always readable, regardless of user permissions.
  #   @return [Boolean]
  always_readable false

  # @!attribute [r] readable_in_dev
  #   @!scope class
  #   Whether the record is readable in development mode.
  #   @note This is mostly for harvesting and other records that allows for easier introspection.
  #   @return [Boolean]
  readable_in_dev false

  pre_check :allow_public_reading!, only: %i[index? show? read?]

  # @param [ApplicationRecord] record
  # @param [User, AnonymousUser] user
  def initialize(record, user: AnonymousUser.new, **options)
    options[:user] = user || AnonymousUser.new

    super
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
  def read? = admin_or_owns_resource?

  # @!parse [ruby]
  #   alias show? read?
  #   alias index? read?
  alias_rule :show?, :index?, to: :read?

  # Sometimes we need to allow read access specifically for use with mutation arguments
  # in a way that differs from normal read access. This happens in other projects, but
  # not here yet. This is here for support with {Types::AbstractModel.authorized?}.
  #
  # For the sake of mutations, assume arguments provided can always be read and worry
  # about authorizing within the context of the mutation.
  def read_for_mutation? = true

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

  # @!group Predicates

  def admin_or_owns_resource?
    return false if anonymous?

    return true if has_admin?

    record_owned_by_current_user?
  end

  # Whether the record is always readable, regardless of user permissions.
  # @see .always_readable
  def always_readable? = self.class.always_readable

  def anonymous? = user.anonymous?

  def has_any_access_management_permissions? = user.can_manage_access_globally? || user.can_manage_access_contextually?

  # Whether the user has global admin access
  def has_admin? = user.has_global_admin_access?

  # @param [String] action_name
  # @return [Boolean] whether the user has been granted the specified action
  def has_allowed_action?(action_name) = action_name.to_s.in?(user.allowed_actions)

  # Whether the user has been granted the specified action, or is a global admin
  # @param [String] action_name
  def has_admin_or_allowed_action?(action_name) = has_admin? || has_allowed_action?(action_name)

  def new_record? = record.try(:new_record?) || false

  # Whether the record is readable in development mode.
  #
  # @see .readable_in_dev
  # @note This is mostly for harvesting and other records that allows for easier introspection.
  def readable_in_dev? = self.class.readable_in_dev && Rails.env.development?

  # @api private
  def record_owned_by_current_user?
    return false if anonymous?

    if record.kind_of?(::User) && !record.anonymous?
      record == user
    elsif record.respond_to?(:user_id)
      record.user_id == user.id
    elsif record.respond_to?(:user)
      record.user == user
    else
      false
    end
  end

  # @!endgroup Predicates

  # @!group Helpers

  # @!attribute [r] user_id
  # @return [String, nil]
  def user_id = anonymous? ? nil : user.id

  # @!endgroup Helpers

  # @!group Pre-checks

  # @api private
  # @return [void]
  def allow_any_admin!
    allow! if has_admin?
  end

  def allow_if_can_update_settings!
    allow! if has_admin_or_allowed_action?("settings.update")
  end

  # @return [void]
  def allow_for_user_owned!
    allow! if record_owned_by_current_user?
  end

  # @return [void]
  def allow_admin_or_for_user_owned!
    allow_any_admin!
    allow_for_user_owned!
  end

  # @api private
  # @return [void]
  def allow_public_reading!
    allow! if always_readable? || readable_in_dev?
  end

  # @api private
  # @return [void]
  def deny_anonymous!
    deny! if anonymous?
  end

  # @!endgroup Pre-checks

  # @!group Overrides

  # @note We override this to reject nil records out of hand without having to do a lot of present? checks.
  def allowed_to?(rule, record = :__undef__, **options)
    # :nocov:
    return false if record.nil?
    # :nocov:

    super
  end

  # @!endgroup Overrides

  # @!group Scope Resolution Helpers

  # @api private
  # @param [ActiveRecord::Relation] relation
  # @return [ActiveRecord::Relation]
  def resolve_default_scope_for(relation)
    if has_admin?
      resolve_scope_for_admin(relation)
    elsif anonymous?
      resolve_scope_for_anonymous(relation)
    else
      resolve_scope_for_authenticated(relation)
    end
  end

  # @api private
  # @param [ActiveRecord::Relation] relation
  # @return [ActiveRecord::Relation]
  def resolve_scope_for_admin(relation)
    relation.all
  end

  # @api private
  # @param [ActiveRecord::Relation] relation
  # @return [ActiveRecord::Relation]
  def resolve_scope_for_non_admin(relation)
    if always_readable? || readable_in_dev?
      relation.all
    else
      relation.none
    end
  end

  # @api private
  # @note Defers to {#resolve_scope_for_non_admin} by default, but can be
  #   overridden to provide different scopes for authenticated vs anonymous users.
  # @param [ActiveRecord::Relation] relation
  # @return [ActiveRecord::Relation]
  def resolve_scope_for_authenticated(relation)
    resolve_scope_for_non_admin(relation)
  end

  # @api private
  # @note Defers to {#resolve_scope_for_non_admin} by default, but can be
  #   overridden to provide different scopes for authenticated vs anonymous users.
  # @param [ActiveRecord::Relation] relation
  # @return [ActiveRecord::Relation]
  def resolve_scope_for_anonymous(relation)
    resolve_scope_for_non_admin(relation)
  end

  relation_scope do |relation|
    resolve_default_scope_for(relation)
  end

  class << self
    # Specify that the record is always readable.
    #
    # @see .always_readable
    # @return [void]
    def always_readable!
      always_readable true
    end

    # Specify that the record is readable in development mode.
    #
    # @see .readable_in_dev
    # @return [void]
    def readable_in_dev!
      readable_in_dev true
    end
  end
end

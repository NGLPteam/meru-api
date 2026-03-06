# frozen_string_literal: true

# @abstract
# @see HierarchicalEntity
class HierarchicalEntityPolicy < ApplicationPolicy
  pre_check :deny_anonymous!, except: %i[index? show? read_assets?]
  pre_check :deny_submission_drafts!, only: %i[reparent? alter_schema_version?]
  pre_check :allow_any_admin!
  pre_check :allow_if_depositor_on_draft!, only: %i[read? show? update?]

  # @return [ContextualPermission, nil]
  attr_reader :contextual_permission

  # @return [Roles::EntityPermissionGrid]
  attr_reader :grid

  def initialize(...)
    super

    @contextual_permission = ContextualPermission.fetch user, record

    @grid = @contextual_permission.try(:grid) || Roles::EntityPermissionGrid.new
  end

  def read? = has_permission?(:read)

  def show?
    return true if read?

    return true unless record.respond_to?(:currently_visible?)

    record.currently_visible?
  end

  alias_rule :index?, to: :show?

  def create? = has_permission?(:create)

  def update? = has_permission?(:update)

  def revalidate? = update?

  def destroy? = has_permission?(:delete)

  def deposit? = has_permission?(:deposit)

  def review? = has_permission?(:review)

  def manage_access? = has_permission?(:manage_access)

  def read_assets? = has_asset_permission?(:read)

  def create_assets? = has_asset_permission?(:create)

  def update_assets? = has_asset_permission?(:update)

  def destroy_assets? = has_asset_permission?(:delete)

  def purge? = has_admin?

  def alter_schema_version? = has_permission?(:update)

  def reparent? = has_permission?(:update)

  def create_collections? = has_hierarchical_scoped_permission?(:collections, :create)

  def create_items? = has_hierarchical_scoped_permission?(:items, :create)

  private

  # @return [void]
  def deny_submission_drafts!
    deny! if record.try(:submission_draft?)
  end

  # @return [void]
  def allow_if_depositor_on_draft!
    allow! if record.try(:submission_draft?) && record.try(:submitter) == user
  end

  # @api private
  # @param [#to_s] name
  # @see Roles::PermissionGrid#[]
  def has_permission?(name) = @grid[name]

  # @api private
  # @param [#to_s] name
  # @see Roles::PermissionGrid#[]
  def has_asset_permission?(name) = @grid.assets[name]

  # @api private
  # @param [#to_s] scope_name e.g. "collections", "items"
  # @param [#to_s] permission_name e.g. "read", "create"
  def has_hierarchical_scoped_permission?(scope_name, permission_name)
    action_name = "#{scope_name}.#{permission_name}"

    AccessGrant.for_user(user).with_allowed_action?(name: action_name, entity: record)
  end

  def show_full_entity_scope? = has_allowed_action?("admin.access")

  def resolve_scope_for_authenticated(relation)
    if show_full_entity_scope?
      relation.all
    else
      relation.currently_visible
    end
  end

  def resolve_scope_for_anonymous(relation)
    relation.currently_visible
  end
end

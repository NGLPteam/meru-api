# frozen_string_literal: true

# @see AccessGrantPolicy
# @see Access::Provisional This also applies to provisional access grants.
class AccessGrantPolicy < ApplicationPolicy
  pre_check :deny_anonymous!
  pre_check :disallow_changing_own_or_admin_role!, only: %i[create? destroy?]
  pre_check :allow_any_admin!, only: %i[create? destroy?]

  def initialize(...)
    super

    @for_admin_role = record.try(:role).try(:identified_as_admin?)
    @is_manager = record.try(:has_manager?, user)
  end

  def read? = @is_manager

  def show? = @is_manager

  def create? = @is_manager

  # Access grants are not updatable by anyone.
  def update? = false

  def destroy? = @is_manager

  def manage_access? = false

  private

  # @return [void]
  def disallow_changing_own_or_admin_role!
    deny! if for_self_or_admin?
  end

  # @return [Boolean]
  attr_reader :for_admin_role

  alias for_admin_role? for_admin_role

  def for_self? = record.subject == user

  def for_self_or_admin? = for_self? || for_admin_role?

  def resolve_scope_for_authenticated(relation)
    relation.manageable_by(user)
  end

  def resolve_scope_for_anonymous(relation)
    relation.none
  end
end

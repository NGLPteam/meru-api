# frozen_string_literal: true

# @see Permalink
class PermalinkPolicy < ApplicationPolicy
  always_readable!

  delegate :permalinkable, to: :record

  def create?
    can_update_permalinkable?
  end

  def update?
    can_update_permalinkable?
  end

  def destroy?
    can_update_permalinkable?
  end

  private

  def can_update_permalinkable?
    return false if user.anonymous?

    return true if has_admin_or_allowed_action?("settings.update")

    # :nocov:
    return false if permalinkable.blank?
    # :nocov:

    authorized?(permalinkable, :update?)
  end

  class Scope < Scope
    # NOTE: Be explicit about which records you allow access to!
    # def resolve
    #   scope.all
    # end
  end
end

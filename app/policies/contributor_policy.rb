# frozen_string_literal: true

class ContributorPolicy < ApplicationPolicy
  pre_check :allow_any_admin!

  def show? = true

  def create? = has_allowed_action?("contributors.create")

  def update? = has_allowed_action?("contributors.update")

  def destroy? = has_allowed_action?("contributors.delete")

  private

  def resolve_scope_for_authenticated(relation)
    relation.all
  end

  def resolve_scope_for_anonymous(relation)
    relation.none
  end
end

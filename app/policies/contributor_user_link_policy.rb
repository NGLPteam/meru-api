# frozen_string_literal: true

# @see ContributorUserLink
class ContributorUserLinkPolicy < ApplicationPolicy
  pre_check :allow_any_admin!, except: %i[create? update?]

  def read? = update_contributor? || read_user?

  def show? = read?

  def create? = false

  def update? = false

  def destroy? = has_allowed_action?("contributors.destroy") || allowed_to?(:destroy?, record.contributor)

  private

  def update_contributor? = has_allowed_action?("contributors.update") || allowed_to?(:update?, record.contributor)

  def read_user? = has_allowed_action?("users.read") || allowed_to?(:read?, record.user)

  def resolve_scope_for_authenticated(relation)
    if has_allowed_action?("contributors.update") || has_allowed_action?("users.read")
      relation.all
    else
      relation.where(user:)
    end
  end
end

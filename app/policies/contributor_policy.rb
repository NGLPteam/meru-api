# frozen_string_literal: true

class ContributorPolicy < ApplicationPolicy
  include PubliclyScopedPolicy

  pre_check :prevent_merge_source_interruption!, except: %i[show? read? read_for_mutation? index? merge_source? merge_target?]
  pre_check :prevent_merge_target_interruption!, only: %i[destroy?]
  pre_check :deny_if_claiming_disabled!, only: %i[claim?]
  pre_check :allow_any_admin!, except: %i[claim?]
  pre_check :deny_anonymous!, except: %i[show?]

  def read? = super || has_allowed_action?("contributors.read")

  def show? = true

  def create? = has_allowed_action?("contributors.create")

  def update? = allowed_to_update_contributors? || allowed_to_update_claimed?

  def destroy? = has_allowed_action?("contributors.delete")

  def claim? = record.unclaimed? && user.may_claim_author?

  def link_user? = allowed_to_update_contributors?

  def merge_source? = allowed_to_merge_contributors? && record.merge_source_available?

  def merge_target? = allowed_to_merge_contributors? && record.merge_target_available?

  private

  def allowed_to_merge_contributors? = has_allowed_action?("contributors.merge")

  def allowed_to_update_contributors? = has_allowed_action?("contributors.update")

  def allowed_to_update_claimed? = owner_updatable? && record.user == user

  def claiming_enabled? = current_global_configuration.contributors.claimable?

  def owner_updatable? = current_global_configuration.contributors.owner_updatable?

  # @return [void]
  def deny_if_claiming_disabled!
    deny! unless claiming_enabled?
  end

  # @return [void]
  def prevent_merge_source_interruption!
    deny! if record.merge_source_busy?
  end

  def prevent_merge_target_interruption!
    deny! if record.merge_prevents_destruction?
  end
end

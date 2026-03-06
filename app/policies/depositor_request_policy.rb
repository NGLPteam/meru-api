# frozen_string_literal: true

# @see DepositorRequest
class DepositorRequestPolicy < ApplicationPolicy
  pre_check :deny_anonymous!

  pre_check :allow_any_admin!

  delegate :submission_target, to: :record

  delegate :entity, to: :submission_target, prefix: :target

  def read? = allowed_to?(:update?, submission_target) || record_owned_by_current_user?

  alias_rule :index?, :show?, to: :read?

  def create? = allowed_to?(:request_deposit_access?, submission_target)

  def update? = false

  def destroy? = false

  def transition? = allowed_to?(:update?, target_entity)

  relation_scope do |relation|
    resolve_default_scope_for(relation)
  end
end

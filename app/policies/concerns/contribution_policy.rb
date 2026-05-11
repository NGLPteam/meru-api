# frozen_string_literal: true

module ContributionPolicy
  extend ActiveSupport::Concern

  def read? = allowed_to?(:read?, record.contributable)

  def show? = allowed_to?(:show?, record.contributable)

  def create? = allowed_to?(:update?, record.contributable)

  def update? = allowed_to?(:update?, record.contributable)

  def destroy? = allowed_to?(:update?, record.contributable)

  private

  def resolve_scope_for_non_admin(relation)
    relation.visible_to(user)
  end
end

# frozen_string_literal: true

# @see Community
class CommunityPolicy < HierarchicalEntityPolicy
  include PubliclyScopedPolicy

  def read? = has_allowed_action?("communities.read") || super

  def create? = has_allowed_action?("communities.create")

  def update? = has_allowed_action?("communities.update") || super

  def destroy? = has_allowed_action?("communities.delete") || super

  private

  def show_full_entity_scope? = has_allowed_action?("communities.read") || super
end

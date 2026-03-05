# frozen_string_literal: true

# Policy logic largely depends on the link's {HierarchicalEntity source entity}.
#
# @see EntityLink
class EntityLinkPolicy < ApplicationPolicy
  include PubliclyScopedPolicy

  def read? = allowed_to?(:read?, record.source)

  def index? = allowed_to?(:index?, record.source)

  def show? = allowed_to?(:show?, record.source)

  def create? = allowed_to?(:update?, record.source)

  def update? = allowed_to?(:update?, record.source)

  def destroy? = allowed_to?(:update?, record.source)
end

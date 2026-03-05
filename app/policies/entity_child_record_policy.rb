# frozen_string_literal: true

# @abstract Policies that inherit from this have most of their permissions
#   dictated from the `:update` permission on a parent `entity` association.
class EntityChildRecordPolicy < ApplicationPolicy
  include PubliclyScopedPolicy

  delegate :entity, to: :record

  def show? = allowed_to?(:show?, entity)

  alias_rule :index?, to: :show?

  def read? = allowed_to?(:read?, entity)

  def create? = allowed_to?(:update?, entity)

  def update? = allowed_to?(:update?, entity)

  def destroy? = allowed_to?(:update?, entity)

  def manage_access? = allowed_to?(:manage_access?, entity)
end

# frozen_string_literal: true

# @see ItemContribution
class ItemContributionPolicy < ApplicationPolicy
  include PubliclyScopedPolicy

  def read? = allowed_to?(:update?, record.item)

  def show? = allowed_to?(:show?, record.item)

  def create? = allowed_to?(:update?, record.item)

  def update? = allowed_to?(:update?, record.item)

  def destroy? = allowed_to?(:update?, record.item)
end

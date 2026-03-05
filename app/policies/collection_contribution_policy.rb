# frozen_string_literal: true

# @see CollectionContribution
class CollectionContributionPolicy < ApplicationPolicy
  include PubliclyScopedPolicy

  def read? = allowed_to?(:update?, record.collection)

  def show? = allowed_to?(:show?, record.collection)

  def create? = allowed_to?(:update?, record.collection)

  def update? = allowed_to?(:update?, record.collection)

  def destroy? = allowed_to?(:update?, record.collection)
end

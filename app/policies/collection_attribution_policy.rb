# frozen_string_literal: true

# @see CollectionAttribution
class CollectionAttributionPolicy < ApplicationPolicy
  include PubliclyScopedPolicy

  def show? = allowed_to?(:show?, record.collection)
end

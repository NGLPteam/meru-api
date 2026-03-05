# frozen_string_literal: true

# @see ItemAttribution
class ItemAttributionPolicy < ApplicationPolicy
  def show? = allowed_to?(:show?, record.item)
end

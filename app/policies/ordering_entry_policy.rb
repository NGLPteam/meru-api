# frozen_string_literal: true

# @see OrderingEntry
class OrderingEntryPolicy < ApplicationPolicy
  always_readable!

  def create? = false

  def update? = false

  def destroy? = false

  def manage_access? = false
end

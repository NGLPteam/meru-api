# frozen_string_literal: true

# @see ContributorAttribution
class ContributorAttributionPolicy < ApplicationPolicy
  always_readable!

  def show? = true

  def create? = false

  def update? = false

  def destroy? = false
end

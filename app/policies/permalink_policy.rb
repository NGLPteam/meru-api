# frozen_string_literal: true

# @see Permalink
class PermalinkPolicy < ApplicationPolicy
  pre_check :deny_anonymous!, only: %i[create? update? destroy?]

  pre_check :allow_if_can_update_settings!, only: %i[create? update? destroy?]

  always_readable!

  delegate :permalinkable, to: :record

  def create? = allowed_to?(:update?, permalinkable)

  def update? = allowed_to?(:update?, permalinkable)

  def destroy? = allowed_to?(:update?, permalinkable)
end

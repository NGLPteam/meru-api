# frozen_string_literal: true

class GlobalConfigurationPolicy < ApplicationPolicy
  always_readable!

  pre_check :allow_any_admin!, only: %i[update?]
  pre_check :allow_if_can_update_settings!, only: %i[update?]

  # Anyone can read global configurations for the most part, as
  # things like the site title, color scheme, and font scheme
  # need to be accessible even to an anonymous user.
  #
  # Privileged attributes will be implemented on a more granular
  # level when they arrive.
  def show? = true

  # No one can create global configurations. There is only one.
  def create? = false

  # A user must be a global admin or have been specifically granted
  # `settings.update` permissions in order to alter the settings.
  def update? = false

  # No one can destroy global configurations.
  def destroy? = false
end

# frozen_string_literal: true

module Roles
  # @see Types::SettingsPermissionGridType
  class SettingsGrid
    include Roles::Grid

    permission :update
  end
end

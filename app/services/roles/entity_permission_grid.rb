# frozen_string_literal: true

module Roles
  class EntityPermissionGrid < PermissionGrid
    permission :deposit, :manage_access, :review

    grid :assets, default: false
  end
end

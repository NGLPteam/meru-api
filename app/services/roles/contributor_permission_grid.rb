# frozen_string_literal: true

module Roles
  # @see Types::ContributorPermissionGridType
  class ContributorPermissionGrid < PermissionGrid
    permission :claim, :merge
  end
end

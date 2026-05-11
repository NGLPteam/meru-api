# frozen_string_literal: true

module Roles
  # @see Types::AdminPermissionGridType
  class AdminPermissionGrid
    include Roles::Grid

    permission :access
  end
end

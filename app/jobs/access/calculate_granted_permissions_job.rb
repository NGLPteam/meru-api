# frozen_string_literal: true

module Access
  # Asynchronously calculate {GrantedPermission} for a specific {AccessGrant}.
  #
  # @see Access::CalculateGrantedPermissions
  class CalculateGrantedPermissionsJob < ApplicationJob
    queue_as :default

    # @param [AccessGrant] access_grant
    # @return [void]
    def perform(access_grant)
      MeruAPI::Container["access.calculate_granted_permissions"].call access_grant:
    end
  end
end

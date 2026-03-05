# frozen_string_literal: true

module Mutations
  module Contracts
    # Check the inputs for revoking access to an entity for a user.
    #
    # @see Access::Revoke
    # @see Mutations::Operations::RevokeAccess
    class RevokeAccess < MutationOperations::Contract
      json do
        required(:entity).value(:any_entity)
        required(:provisional).value(:provisional_access_grant)
        required(:role).value(:role)
        required(:user).value(:user)
      end

      rule(:role) do
        key(:role_id).failure(:cannot_revoke_unassignable_role, role_name: value.name) unless values[:provisional].apply?
      end

      rule(:user) do
        key(:$global).failure(:cannot_revoke_role_from_self) if value == current_user
      end
    end
  end
end

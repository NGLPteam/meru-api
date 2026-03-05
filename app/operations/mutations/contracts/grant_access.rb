# frozen_string_literal: true

module Mutations
  module Contracts
    # Check the inputs for granting access to an entity for a user.
    class GrantAccess < MutationOperations::Contract
      json do
        required(:entity).value(:any_entity)
        required(:provisional).value(:provisional_access_grant)
        required(:role).value(:role)
        required(:user).value(:user)
      end

      rule(:role) do
        key(:role_id).failure(:cannot_grant_unassignable_role, role_name: value.name) unless values[:provisional].apply?
      end

      rule(:user) do
        key(:$global).failure(:cannot_grant_role_to_self) if value == current_user
      end
    end
  end
end

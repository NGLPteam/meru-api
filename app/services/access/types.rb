# frozen_string_literal: true

module Access
  # Types for Access-related operations and services.
  module Types
    extend ::Support::Typespace

    # @see AccessGrant
    AccessGrant = ModelInstance("AccessGrant")

    # @see HierarchicalEntity
    Entity = Instance(::HierarchicalEntity)

    # @see Role
    Role = ModelInstance("Role")

    # @see User
    AuthenticatedUser = ModelInstance("User")
  end
end

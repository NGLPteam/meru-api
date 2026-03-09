# frozen_string_literal: true

# An inferred connection between a {ContextualPermission} and a {Role}.
class ContextuallyAssignedRole < ApplicationRecord
  include GenericInaccessible
  include ContextuallyDerivedConnection

  contextual_primary_key! :role_id

  belongs_to_contextual_permission inverse_of: :contextually_assigned_roles

  belongs_to_readonly :role, inverse_of: :contextually_assigned_roles
end

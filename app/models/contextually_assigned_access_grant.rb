# frozen_string_literal: true

# An inferred connection between a {ContextualPermission} and an {AccessGrant}.
class ContextuallyAssignedAccessGrant < ApplicationRecord
  include GenericInaccessible
  include ContextuallyDerivedConnection

  contextual_primary_key! :access_grant_id

  belongs_to_contextual_permission inverse_of: :contextually_assigned_access_grants

  belongs_to_readonly :access_grant, inverse_of: :contextually_assigned_access_grants
end

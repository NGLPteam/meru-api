# frozen_string_literal: true

# @see AssignableRoleTarget
class ContextuallyAssignableRole < ApplicationRecord
  include GenericInaccessible
  include ContextuallyDerivedConnection

  contextual_primary_key! :role_id

  belongs_to_contextual_permission inverse_of: :contextually_assignable_roles

  belongs_to_readonly :role
  belongs_to_readonly :user

  scope :in_order, -> { order(priority: :asc) }
end

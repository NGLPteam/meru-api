# frozen_string_literal: true

# The primary {Role} assigned to an {AccessGrantSubject} via {AccessGrant}.
class PrimaryRoleAssignment < ApplicationRecord
  include GenericAccessible
  include View

  belongs_to :subject, polymorphic: true, inverse_of: :primary_role_assignment
  belongs_to :role, inverse_of: :primary_role_assignments
end

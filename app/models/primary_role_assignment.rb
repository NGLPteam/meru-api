# frozen_string_literal: true

# The primary {Role} assigned to an {AccessGrantSubject} via {AccessGrant}.
class PrimaryRoleAssignment < ApplicationRecord
  include GenericAccessible
  include View

  self.primary_key = %i[subject_type subject_id]

  belongs_to :subject, polymorphic: true, inverse_of: :primary_role_assignment
  belongs_to :role, inverse_of: :primary_role_assignments
end

# frozen_string_literal: true

# A materialized view that determines which {Role target_role} another {Role source_role} has available
# to assign. It requires that the `source_role` has some level of `*.manage_access` available, and will
# be further filtered at the contextual level, if necessary.
class AssignableRoleTarget < ApplicationRecord
  include GenericInaccessible
  include MaterializedView

  # @return [Role]
  belongs_to_readonly :source_role, class_name: "Role", inverse_of: :assignable_role_targets

  # @return [Role]
  belongs_to_readonly :target_role, class_name: "Role", inverse_of: :assignable_role_sources

  scope :in_order, -> { order(priority: :asc) }
end

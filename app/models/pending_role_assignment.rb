# frozen_string_literal: true

# A view that calculates any roles that need to be applied based on some variable conditions.
#
# At present, it only works to ensure that admin users have their roles available.
class PendingRoleAssignment < ApplicationRecord
  include GenericInaccessible
  include View

  self.primary_key = %i[accessible_type accessible_id role_id subject_type subject_id]

  belongs_to_readonly :accessible, polymorphic: true
  belongs_to_readonly :role
  belongs_to_readonly :subject, polymorphic: true

  scope :for_subject, ->(subject) { where(subject:) }
  scope :for_possible_subject, ->(subject) { for_subject(subject) if subject.present? }

  scope :to_assign, -> { preload(:accessible, :role, :subject) }

  # @see Access::Grant#call
  # @return [Hash]
  def to_grant_options
    {
      to: subject,
      on: accessible
    }
  end
end

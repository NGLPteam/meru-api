# frozen_string_literal: true

# A view that derives information about how a {User} can manage access
# to entities within the system.
#
# @see Users::AccessInfo
class UserAccessInfo < ApplicationRecord
  include GenericAccessible
  include HasEphemeralSystemSlug
  include TimestampScopes
  include View

  self.primary_key = :user_id

  pg_enum! :access_management, as: :access_management, suffix: :access_management

  belongs_to :user, inverse_of: :access_info

  def to_wrapped
    slice(:access_management, :can_manage_access_globally, :can_manage_access_contextually)
  end
end

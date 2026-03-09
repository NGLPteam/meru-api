# frozen_string_literal: true

class CommunityMembership < ApplicationRecord
  include GenericAccessible
  include TimestampScopes

  belongs_to :community, inverse_of: :community_memberships
  belongs_to :role, optional: true, inverse_of: :community_memberships
  belongs_to :user, inverse_of: :community_memberships

  after_commit :sync_access_grant!

  # @!private
  # @return [void]
  def sync_access_grant!
    return if role.blank?

    MeruAPI::Container["access.grant"].call(role, on: community, to: user).value!
  end
end

# frozen_string_literal: true

module Types
  module Settings
    # @see Settings::Contributors
    # @see Types::Settings::ContributorsSettingsType
    class ContributorsSettingsInputType < Types::HashInputObject
      description <<~TEXT
      Settings related to how contributors are handled in this installation.
      TEXT

      argument :claimable, Boolean, required: false, default_value: MeruConfig.contributor_claimable, replace_null_with_default: true do
        description <<~TEXT
        Whether users can claim ownership of an unclaimed contributor in this installation.
        TEXT
      end

      argument :owner_updatable, Boolean, required: false, default_value: MeruConfig.contributor_owner_updatable, replace_null_with_default: true do
        description <<~TEXT
        Whether users who have claimed a contributor can manage that contributor
        without needing to be an admin or anything else.
        TEXT
      end
    end
  end
end

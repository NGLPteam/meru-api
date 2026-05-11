# frozen_string_literal: true

module Types
  module Settings
    # @see Settings::Contributors
    # @see Types::Settings::ContributorsSettingsInputType
    class ContributorsSettingsType < Types::BaseObject
      description <<~TEXT
      Settings related to how contributors are handled in this installation.
      TEXT

      field :claimable, Boolean, null: false do
        description <<~TEXT
        Whether users can claim ownership of an unclaimed contributor in this installation.
        TEXT
      end

      field :owner_updatable, Boolean, null: false do
        description <<~TEXT
        Whether users who have claimed a contributor can manage that contributor
        without needing to be an admin or anything else.
        TEXT
      end
    end
  end
end

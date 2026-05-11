# frozen_string_literal: true

module Settings
  # Settings for depositing to this installation.
  # @see GlobalConfiguration
  # @see ::Types::Settings::ContributorsSettingsInputType
  # @see ::Types::Settings::ContributorsSettingsType
  class Contributors
    include Support::EnhancedStoreModel

    strip_attributes allow_empty: true, collapse_spaces: true

    attribute :claimable, :boolean, default: MeruConfig.contributor_claimable

    attribute :owner_updatable, :boolean, default: MeruConfig.contributor_owner_updatable
  end
end

# frozen_string_literal: true

module Settings
  # Settings related to how entities behave.
  #
  # @see GlobalConfiguration
  # @see ::Types::Settings::EntitiesSettingsInputType
  # @see ::Types::Settings::EntitiesSettingsType
  class Entities
    include Support::EnhancedStoreModel

    attribute :suppress_external_links, :boolean, default: false

    def reset!
      self.suppress_external_links = false
    end
  end
end

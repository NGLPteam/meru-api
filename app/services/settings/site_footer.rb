# frozen_string_literal: true

module Settings
  # @see GlobalConfiguration
  # @see ::Types::Settings::SiteFooterSettingsInputType
  # @see ::Types::Settings::SiteFooterSettingsType
  class SiteFooter
    include Support::EnhancedStoreModel

    strip_attributes collapse_spaces: true

    attribute :description, :string, default: ""
    attribute :copyright_statement, :string, default: ""

    validates :description, :copyright_statement, enforced_string: true

    # @return [void]
    def reset!
      self.description = ""
      self.copyright_statement = ""
    end
  end
end

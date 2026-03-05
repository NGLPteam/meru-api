# frozen_string_literal: true

module Settings
  # Settings related to the site as a whole.
  #
  # @see GlobalConfiguration
  # @see ::Types::Settings::SiteSettingsInputType
  # @see ::Types::Settings::SiteSettingsType
  class Site
    include Support::EnhancedStoreModel

    strip_attributes collapse_spaces: true

    actual_enum :logo_mode, :none, :sans_text, :with_text, default: :none, prefix: :logo

    attribute :installation_name, :string, default: ""
    attribute :installation_home_page_copy, :string, default: ""
    attribute :provider_name, :string, default: ""
    attribute :footer, Settings::SiteFooter.to_type, default: {}

    validates :installation_name, :installation_home_page_copy, :provider_name, enforced_string: true
    validates :footer, store_model: true

    def logo_mode_set?
      !logo_none?
    end

    # @return [void]
    def reset!
      self.installation_name = ""
      self.installation_home_page_copy = ""
      self.provider_name = ""
      footer.reset!
    end
  end
end

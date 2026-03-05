# frozen_string_literal: true

module Types
  module Settings
    # @see ::Settings::Site
    class SiteSettingsType < Types::BaseObject
      description <<~TEXT
      Configuration settings for information about this installation.
      TEXT

      field :installation_name, String, null: false do
        description <<~TEXT
        The name of the installation.
        TEXT
      end

      field :installation_home_page_copy, String, null: false do
        description <<~TEXT
        The text that appears on the root page of the frontend. Supports basic markdown.
        TEXT
      end

      field :logo_mode, Types::SiteLogoModeType, null: false do
        description <<~TEXT
        How the logo should be rendered.
        TEXT
      end

      field :provider_name, String, null: false do
        description <<~TEXT
        The name of the provider supporting and maintaining this installation.
        TEXT
      end

      field :footer, SiteFooterType, null: false do
        description <<~TEXT
        Settings related to the site's footer.
        TEXT
      end
    end
  end
end

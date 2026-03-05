# frozen_string_literal: true

module Types
  module Settings
    # @see ::Settings::Site
    class SiteSettingsInputType < Types::HashInputObject
      description <<~TEXT
      A value for updating the site's configuration.
      TEXT

      argument :installation_name, String, required: false do
        description <<~TEXT
        The name of the installation.
        TEXT
      end

      argument :installation_home_page_copy, String, required: false do
        description <<~TEXT
        The text that appears on the root page of the frontend. Supports basic markdown.
        TEXT
      end

      argument :logo_mode, Types::SiteLogoModeType, required: false do
        description <<~TEXT
        How the logo should be rendered.
        TEXT
      end

      argument :provider_name, String, required: false do
        description <<~TEXT
        The name of the provider supporting and maintaining this installation.
        TEXT
      end

      argument :footer, SiteFooterInputType, required: false do
        description <<~TEXT
        Settings for the site's footer.
        TEXT
      end
    end
  end
end

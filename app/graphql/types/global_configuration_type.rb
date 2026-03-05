# frozen_string_literal: true

module Types
  # @see GlobalConfiguration
  class GlobalConfigurationType < Types::BaseObject
    implements GraphQL::Types::Relay::Node

    global_id_field :id

    description "The global configuration for this installation of Meru."

    field :contribution_roles, Types::ContributionRoleConfigurationType, null: false do
      description <<~TEXT
      Global configuration for contribution roles.
      TEXT
    end

    field :depositing, Types::Settings::DepositingSettingsType, null: false do
      description "Settings specific to depositing to this installation."
    end

    field :entities, Types::Settings::EntitiesSettingsType, null: false do
      description "Settings specific to how entities should behave on this installation."
    end

    field :institution, Types::Settings::InstitutionSettingsType, null: false do
      description "Settings specific to this institution."
    end

    field :logo, Types::SiteLogoAttachmentType, null: false do
      description "The logo attachment. It may not always be present."
    end

    field :logo_metadata, Types::ImageMetadataType, null: true do
      description "Configurable metadata for the logo attachment."
    end

    field :site, Types::Settings::SiteSettingsType, null: false do
      description "Settings specific to this site"
    end

    field :theme, Types::Settings::ThemeSettingsType, null: false do
      description "Settings specific to the site's theme"
    end

    load_association! :contribution_role_configuration, as: :contribution_roles

    # @return [ImageAttachments::SiteLogoWrapper]
    def logo
      attacher = object.logo_attacher

      ImageAttachments::SiteLogoWrapper.new attacher, purpose: "site_logo"
    end
  end
end

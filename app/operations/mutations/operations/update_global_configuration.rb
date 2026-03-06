# frozen_string_literal: true

module Mutations
  module Operations
    # @see GlobalConfiguration
    # @see Mutations::UpdateGlobalConfiguration
    class UpdateGlobalConfiguration
      include MutationOperations::Base

      use_contract! :update_global_configuration

      attachment! :logo, image: true

      authorizes! :config, with: :update?

      # @param [GlobalConfiguration] config
      def call(config:, contribution_roles: nil, depositing: nil, entities: nil, institution: nil, site: nil, theme: nil, **args)
        config.depositing = depositing if depositing.present?

        config.entities = entities if entities.present?

        config.institution = institution if institution.present?

        if site.present?
          footer = site.delete(:footer)

          config.site = config.site.as_json.deep_symbolize_keys.merge(site)

          config.site.footer = footer if footer.present?
        end

        config.theme = theme if theme.present?

        assign_attributes!(config, **args)

        if contribution_roles.present?
          config.contribution_role_configuration.assign_attributes(contribution_roles)
        end

        persist_model! config, attach_to: :global_configuration
      end

      before_prepare def fetch_config!
        args[:config] = GlobalConfiguration.fetch
      end
    end
  end
end

# frozen_string_literal: true

module ContributionRoles
  # @see ContributionRoles::FetchConfig
  class ConfigFetcher < Support::HookBased::Actor
    include Dry::Initializer[undefined: false].define -> do
      option :contributable, ContributionRoles::Types::Contributable.optional, optional: true
    end

    standard_execution!

    # @return [ContributionRoleConfiguration]
    attr_reader :contribution_role_configuration

    delegate :schema_version, to: :contributable, prefix: true

    delegate :contribution_role_configuration, to: :contributable_schema_version, prefix: :contributable_schema

    # @return [Dry::Monads::Success(ContributionRoleConfiguration)]
    def call
      run_callbacks :execute do
        yield prepare!
      end

      Success contribution_role_configuration
    end

    wrapped_hook! def prepare
      @contribution_role_configuration = nil

      @contribution_role_configuration ||= find_for_contributable

      @contribution_role_configuration ||= fetch_global_configuration

      # simplecov:disable
      raise "No default contribution role configuration." if contribution_role_configuration.blank?
      # simplecov:enable

      super
    end

    private

    # @return [ContributionRoleConfiguration]
    def fetch_global_configuration
      global_configuration = GlobalConfiguration.fetch

      global_configuration.contribution_role_configuration
    end

    # @return [ContributionRoleConfiguration, nil]
    def find_for_contributable
      return nil if contributable.blank?

      entity = contributable

      loop do
        break if entity.nil?

        config = entity.contribution_role_configuration

        return config if config.present?

        entity = entity.hierarchical_parent
      end

      contributable.schema_version.contribution_role_configuration
    end
  end
end

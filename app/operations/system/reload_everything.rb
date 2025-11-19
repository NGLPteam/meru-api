# frozen_string_literal: true

module System
  # @api private
  class ReloadEverything
    include Dry::Monads[:result, :do]
    include MeruAPI::Deps[
      populate_sources: "controlled_vocabularies.populate_sources",
      reload_controlled_vocabularies: "controlled_vocabularies.static.seed_all",
      reload_roles: "roles.sync",
      reload_schemas: "schemas.static.load_definitions",
    ]

    def call(skip_refresh: false)
      now = Time.current

      yield reload_controlled_vocabularies.call

      yield reload_roles.call

      yield reload_schemas.call

      SchemaVersion.where(updated_at: now..).find_each do |sv|
        # :nocov:
        warn "Refreshing #{sv.declaration} instances" unless Rails.env.test?
        # :nocov:

        Schemas::Versions::ResetAllOrderingsJob.perform_later sv
      end unless skip_refresh

      yield populate_sources.()

      Frontend::Cache::RevalidateInstanceJob.set(wait: 1.minute).perform_later

      Success()
    end
  end
end

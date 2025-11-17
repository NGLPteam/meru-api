# frozen_string_literal: true

require_relative "boot"

require "rails"
# Pick the frameworks you want:
require "active_model/railtie"
require "active_job/railtie"
require "active_record/railtie"
# require "active_storage/engine"
require "action_controller/railtie"
require "action_mailer/railtie"
# require "action_mailbox/engine"
# require "action_text/engine"
require "action_view/railtie"
require "action_cable/engine"
# require "sprockets/railtie"
# require "rails/test_unit/railtie"

require "good_job/engine"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

require_relative "../lib/patches/alter_store_model_mutation_tracking"
require_relative "../lib/patches/better_migration_timestamps"
require_relative "../lib/patches/graphql_use_activesupport_inflection"
require_relative "../lib/patches/handle_weird_redis_openssl_errors"
require_relative "../lib/patches/improve_oai"
require_relative "../lib/patches/liquid_template_enhancements"
require_relative "../lib/patches/parse_graphql_json"
require_relative "../lib/patches/set_search_path_for_dump"
require_relative "../lib/patches/support_calculated_fields_with_aggregates"
require_relative "../lib/patches/support_websearch"

require_relative "../lib/support/system"

module MeruAPI
  class Application < Rails::Application
    # Configure the path for configuration classes that should be used before initialization
    # NOTE: path should be relative to the project root (Rails.root)
    # config.anyway_config.autoload_static_config_path = "config/configs"
    #
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    config.active_support.isolation_level = :fiber

    config.active_record.schema_format = :sql

    config.action_cable.disable_request_forgery_protection = true

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(
      ignore: %w[
        assets
        controlled_vocabularies
        cops
        example_queries
        frozen_record
        generators
        global_types
        graphql
        harvesting
        middleware
        namespaces
        patches
        schemas
        support
        tasks
        templates
        templating
      ]
    )

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.eager_load_paths << Rails.root.join("operations")
    config.eager_load_paths << Rails.root.join("services")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    config.generators do |g|
      g.integration_specs false

      g.orm :active_record, primary_key_type: :uuid
    end

    if Rails.env.development?
      config.hosts << "www.example.com"
      config.hosts << "host.docker.internal"
      config.hosts << /[a-z0-9.-]+\.ngrok\.io/
      config.hosts << /[a-z0-9.-]+\.ngrok-free\.app/
    end

    config.active_record.query_log_tags = [
      # Rails query log tags:
      :application, :controller, :action, :job,
      # GraphQL-Ruby query log tags:
      {
        current_graphql_operation: -> { GraphQL::Current.operation_name },
        current_graphql_field: -> { GraphQL::Current.field&.path },
        current_dataloader_source: -> { GraphQL::Current.dataloader_source_class },
      },
    ]
  end
end

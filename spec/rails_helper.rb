# frozen_string_literal: true

require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require "simplecov"

SimpleCov.start "rails" do
  enable_coverage :branch

  groups.delete "Channels"
  groups.delete "Helpers"
  groups.delete "Libraries"
  groups.delete "Mailers"

  add_group "GraphQL", "app/graphql"
  add_group "Harvesting", [
    "app/jobs/harvesting",
    %r|app/models/harvest|,
    %r|app/models/concerns/[^/]*harvest|,
    "app/operations/harvesting",
    "app/operations/pilot_harvesting",
    "app/services/harvesting",
    "app/services/pilot_harvesting",
  ]
  add_group "Operations", "app/operations"
  add_group "Policies", "app/policies"
  add_group "Services", "app/services"
  add_group "Uploaders", "app/uploaders"

  # Analytics simulations
  add_filter "app/jobs/analytics/simulate_all_visits_job.rb"
  add_filter "app/operations/analytics/simulate_fake_entity_history.rb"
  add_filter "app/services/analytics/fake_entity_visit_history_simulator.rb"
  add_filter "app/services/analytics/simulator_observer.rb"

  add_filter "app/operations/testing"
  add_filter "app/services/harvesting/testing"
  add_filter "app/services/templates/refinements"
  add_filter "app/services/testing"
  add_filter "app/services/tus_client"
  add_filter "lib/cops"
  add_filter "lib/generators"
  add_filter "lib/namespaces"
  add_filter "lib/patches"
  add_filter "lib/support"
  add_filter "spec/support"
end unless defined?(Rails) && !Rails.env.test?

require File.expand_path("../config/environment", __dir__)

abort("The Rails environment is running in production mode!") if Rails.env.production?

require "rspec/rails"
require "rspec/json_expectations"
require "test_prof/recipes/rspec/let_it_be"
require "dry/container/stub"
require "pundit/rspec"
# NOTE: We specifically do not use webmock/rspec because we want
# control over how stubbed stuff gets reset.
require "webmock"
require "webmock/rspec/matchers"

WebMock::AssertionFailure.error_class = RSpec::Expectations::ExpectationNotMetError

# Add additional requires below this line. Rails is not loaded until this point!

Rails.application.eager_load!

ActiveJob::Base.queue_adapter = :test

Shrine.logger = Logger.new(File::NULL)

Dry::Effects.load_extensions :rspec

require_relative "system/test_container"

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end if Rails.env.test?

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Rails.root.glob('spec/support/**/*.rb').each { |f| require f }

FactoryBot::Evaluator.include TestHelpers::Factories::SchemaHelpers

STUB_HARVEST_PROVIDERS = proc do
  Harvesting::Testing::ProviderDefinition.each do |provider|
    provider.webmock_patterns.each do |(verb, pattern)|
      WebMock.stub_request(verb, pattern).to_rack(provider.rack_app)
    end
  end

  broken_provider = Harvesting::Testing::OAI::Broken::Provider.new

  WebMock.stub_request(:get, /\A#{broken_provider.url}/).to_rack(broken_provider.rack_app)

  keycloak_url = KeycloakRack::Config.new.server_url

  WebMock.stub_request(:any, /\A#{keycloak_url}/).to_rack(Testing::Keycloak::Application.instance)

  WebMock.stub_request(:get, "http://api.sandbox.meru.host/samples/sample.pdf")
    .to_return(
      body: proc { Rails.root.join("spec", "data", "sample.pdf").open("r+") },
      headers: {
        "Content-Type": "application/pdf",
      }
    )
end

RSpec.configure do |config|
  # We use database cleaner to do this
  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner[:active_record].strategy = :transaction
    DatabaseCleaner[:redis].strategy = :deletion

    DatabaseCleaner[:active_record].clean_with(:truncation)
    DatabaseCleaner[:redis].clean_with(:deletion)

    Scenic.database.views.select(&:materialized).each do |view|
      Scenic.database.refresh_materialized_view view.name, concurrently: false, cascade: false
    end
  end

  config.include WebMock::API
  config.include WebMock::Matchers

  config.before(:suite) do
    WebMock.enable!
    WebMock.disable_net_connect!
  end

  config.after(:suite) do
    WebMock.disable!
  end

  config.before(:all, &STUB_HARVEST_PROVIDERS)
  config.after(:all, &STUB_HARVEST_PROVIDERS)

  config.around do |example|
    STUB_HARVEST_PROVIDERS.()

    example.run

    WebMock.reset!

    STUB_HARVEST_PROVIDERS.()
  end

  config.before(:suite) do
    Common::Container["system.reload_everything"].(skip_refresh: true).value!
    TestingAPI::TestContainer["initialize_database"].().value!
  end

  config.around do |example|
    DatabaseCleaner.cleaning do
      example.run
    end
  end

  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!

  # Include AJ Test helpers in all specs.
  config.include ActiveJob::TestHelper

  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
end

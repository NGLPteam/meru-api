# frozen_string_literal: true

require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require "simplecov"

SimpleCov.start "rails" do
  disable_coverage :line
  enable_coverage :oneshot_line
  primary_coverage :oneshot_line
  enable_coverage :branch

  groups.delete "Channels"
  groups.delete "Helpers"
  groups.delete "Libraries"
  groups.delete "Mailers"

  depositing_model_bases = %w[
    depositor_agreement
    depositor_agreement_transition
    depositor_request
    depositor_request_transition
    submission_batch_publication_transition
    submission_batch_publication
    submission_comment
    submission_deposit_target
    submission_publication_transition
    submission_publication
    submission_review_transition
    submission_review
    submission_target_reviewer
    submission_target_schema_version
    submission_target_transition
    submission_target
    submission_transition
    submission
  ]

  depositing_models = depositing_model_bases.flat_map do |base|
    [
      "app/models/#{base}.rb",
      "app/policies/#{base}_policy.rb",
    ]
  end + [
    "app/models/concerns/submittable.rb",
    "app/graphql/types/submittable_type.rb",
    %r[app/graphql/mutations/depositor[^/]*\.rb\z],
    %r[app/graphql/types/depositor[^/]*\.rb\z],
    %r[app/graphql/mutations/submission[^/]*\.rb\z],
    %r[app/graphql/types/submission[^/]*\.rb\z],
  ]

  depositing_namespaces = depositing_model_bases.map { "#{_1}s" }

  depositing_dirs = depositing_namespaces.flat_map do |namespace|
    [
      "app/jobs/#{namespace}",
      "app/operations/#{namespace}",
      "app/policies/#{namespace}",
      "app/services/#{namespace}",
    ]
  end

  group "Depositing", [
    *depositing_models,
    *depositing_dirs,
  ]

  group "GraphQL", "app/graphql"

  group "Harvesting", [
    "app/jobs/harvesting",
    %r|app/models/[^/]*harvest|,
    %r|app/models/concerns/[^/]*harvest|,
    "app/operations/harvesting",
    "app/operations/metadata",
    "app/operations/protocols",
    "app/services/harvesting",
    "app/services/metadata",
    "app/services/protocols",
  ]

  group "Mutations", [
    "app/graphql/mutations",
    "app/operations/mutations",
    "app/services/mutation_operations",
  ]

  group "Rendering", [
    %r|app/graphql/types/[^/]*layout|,
    %r|app/graphql/types[^/]*template|,
    %r|app/models/[^/]*layout|,
    %r|app/models/[^/]*template|,
    "app/models/rendering",
    "app/operations/layouts",
    "app/operations/rendering",
    "app/operations/templates",
    "app/services/layouts",
    "app/services/rendering",
    "app/services/templates",
  ]

  group "Operations", "app/operations"
  group "Policies", "app/policies"
  group "Services", "app/services"
  group "Uploaders", "app/uploaders"

  # Analytics simulations
  skip "app/jobs/analytics/simulate_all_visits_job.rb"
  skip "app/operations/analytics/simulate_fake_entity_history.rb"
  skip "app/services/analytics/fake_entity_visit_history_simulator.rb"
  skip "app/services/analytics/simulator_observer.rb"

  skip "app/operations/testing"
  skip "app/services/harvesting/testing"
  skip "app/services/templates/refinements"
  skip "app/services/testing"
  skip "app/services/tus_client"
  skip "lib/cops"
  skip "lib/generators"
  skip "lib/namespaces"
  skip "lib/patches"
  skip "lib/support"
  skip "spec/support"
end unless defined?(Rails) && !Rails.env.test?

require File.expand_path("../config/environment", __dir__)

abort("The Rails environment is running in production mode!") if Rails.env.production?

require "rspec/rails"
require "rspec/json_expectations"
require "test_prof/any_fixture/dsl"
require "test_prof/recipes/rspec/any_fixture"
require "test_prof/recipes/rspec/let_it_be"
require "test_prof/recipes/rspec/sample"
require "dry/container/stub"
require "action_policy/rspec"
require "action_policy/rspec/dsl"
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

TestProf.configure do |config|
  # the directory to put artifacts (reports) in ('tmp/test_prof' by default)
  config.output_dir = "spec/profiles"

  # use unique filenames for reports (by simply appending current timestamp)
  config.timestamps = true

  # color output
  config.color = true
end

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
  config.include ActiveJob::TestHelper
  config.include TestProf::AnyFixture::DSL
  config.include WebMock::API
  config.include WebMock::Matchers

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!

  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  config.infer_spec_type_from_file_location!

  # We use database cleaner to do this
  config.use_transactional_fixtures = false

  config.before(:suite) do
    DatabaseCleaner[:active_record].clean_with(:truncation)
    DatabaseCleaner[:redis].clean_with(:deletion)

    DatabaseCleaner[:active_record].strategy = :transaction
    DatabaseCleaner[:redis].strategy = :deletion

    Scenic.database.views.select(&:materialized).each do |view|
      Scenic.database.refresh_materialized_view view.name, concurrently: false, cascade: false
    end
  end

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

    DatabaseCleaner.cleaning do
      example.run
    end

    WebMock.reset!

    STUB_HARVEST_PROVIDERS.()
  end

  config.before(:suite) do
    TestingAPI::TestContainer["initialize_database"].().value!
  end
end

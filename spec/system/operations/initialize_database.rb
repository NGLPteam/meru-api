# frozen_string_literal: true

module Testing
  # This is used to prepare the test database with certain records
  # that should always exist in the API. Override as necessary
  #
  # We need to load our fixtures in a `before(:suite)` block because
  # we also use let_it_be, and let_it_be's `before_all` messes with
  # the normal RSpec `before(:all)`.
  class InitializeDatabase
    include ActiveSupport::Benchmarkable
    include Dry::Monads[:do, :result]
    include TestProf::AnyFixture::DSL

    include Common::Deps[
      reload_everything: "system.reload_everything",
    ]

    delegate :logger, to: Rails

    def call
      benchmark "Reloading system data" do
        yield reload_everything.call(skip_refresh: true)
      end

      benchmark "Loading role fixtures" do
        load_role_fixtures!
      end

      benchmark "Loading user fixtures" do
        load_user_fixtures!
      end

      benchmark "Loading entity fixtures" do
        load_entity_fixtures!
      end

      benchmark "Loading depositing fixtures" do
        load_depositing_fixtures!
      end

      Success nil
    end

    private

    # @return [void]
    def load_role_fixtures!
      fixture(:role_admin) do
        Role.fetch(:admin)
      end

      fixture(:role_manager) do
        Role.fetch(:manager)
      end

      fixture(:role_editor) do
        Role.fetch(:editor)
      end

      fixture(:role_reviewer) do
        Role.fetch(:reviewer)
      end

      fixture(:role_depositor) do
        Role.fetch(:depositor)
      end

      fixture(:role_author) do
        Role.fetch(:author)
      end

      fixture(:role_reader) do
        Role.fetch(:reader)
      end
    end

    # @return [void]
    def load_user_fixtures!
      fixture(:admin_user) do
        FactoryBot.create :user, :admin, given_name: "Admin", family_name: "User", email: "admin@example.com", testing: false, created_at: 4.days.ago
      end

      fixture(:regular_user) do
        FactoryBot.create :user, given_name: "Test", family_name: "User", email: "test@example.com", created_at: 1.day.ago
      end
    end

    # @return [void]
    def load_entity_fixtures!
      fixture(:item_schema_version) do
        FactoryBot.create(:schema_version, :item, name: "Entity Authorization Test Item Schema")
      end

      fixture(:community) do
        FactoryBot.create(:community, title: "Entity Authorization Test Community")
      end

      fixture(:collection) do
        FactoryBot.create(:collection, community: fixture(:community), title: "Entity Authorization Test Collection")
      end

      fixture(:item) do
        FactoryBot.create(:item, collection: fixture(:collection), title: "Entity Authorization Test Item")
      end

      fixture(:community_manager) do
        FactoryBot.create(:user, given_name: "Community", family_name: "Manager", manager_on: fixture(:community))
      end

      fixture(:community_editor) do
        FactoryBot.create(:user, given_name: "Community", family_name: "Editor", editor_on: fixture(:community))
      end

      fixture(:community_reader) do
        FactoryBot.create(:user, given_name: "Community", family_name: "Reader", reader_on: fixture(:community))
      end

      fixture(:collection_editor) do
        FactoryBot.create(:user, given_name: "Collection", family_name: "Editor", editor_on: fixture(:collection))
      end
    end

    # @return [void]
    def load_depositing_fixtures!
      fixture(:submission_target) do
        fixture(:collection).fetch_submission_target!.tap do |st|
          st.configure!(schema_versions: [fixture(:item_schema_version)], deposit_mode: :direct)
          st.transition_to! :open
        end
      end

      fixture(:reviewer) do
        FactoryBot.create(:user, reviewer_on: fixture(:collection))
      end

      fixture(:submitter) do
        FactoryBot.create(:user, depositor_on: fixture(:collection))
      end

      fixture(:submission) do
        FactoryBot.create(:submission,
          submission_target: fixture(:submission_target),
          schema_version: fixture(:item_schema_version),
          parent_entity: fixture(:collection),
          user: fixture(:submitter),
          title: "Test Submission"
        )
      end
    end
  end
end

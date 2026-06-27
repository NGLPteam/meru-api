# frozen_string_literal: true

RSpec.shared_context "all roles" do
  let_it_be(:role_admin, refind: true) { Role.fetch(:admin) }
  let_it_be(:role_manager, refind: true) { Role.fetch(:manager) }
  let_it_be(:role_editor, refind: true) { Role.fetch(:editor) }
  let_it_be(:role_reviewer, refind: true) { Role.fetch(:reviewer) }
  let_it_be(:role_depositor, refind: true) { Role.fetch(:depositor) }
  let_it_be(:role_author, refind: true) { Role.fetch(:author) }
  let_it_be(:role_reader, refind: true) { Role.fetch(:reader) }
end

RSpec.shared_context "all standard users" do
  let_it_be(:admin_user, refind: true) { FactoryBot.create :user, :admin }

  let_it_be(:admin) { admin_user }

  let_it_be(:regular_user, refind: true) { FactoryBot.create :user }

  let_it_be(:anonymous_user) { AnonymousUser.new }
end

RSpec.shared_context "authorization testing" do
  include_context "all roles"
  include_context "all standard users"
end

RSpec.shared_context "entity authorization testing" do
  include_context "authorization testing"

  let_it_be(:item_schema_version, refind: true) { FactoryBot.create(:schema_version, :item) }

  let_it_be(:community, refind: true) { FactoryBot.create(:community) }
  let_it_be(:collection, refind: true) { FactoryBot.create(:collection, community:) }
  let_it_be(:item, refind: true) { FactoryBot.create(:item, collection:) }

  let_it_be(:community_manager, refind: true) { FactoryBot.create(:user, manager_on: community) }
  let_it_be(:community_editor, refind: true) { FactoryBot.create(:user, editor_on: community) }
  let_it_be(:community_reader, refind: true) { FactoryBot.create(:user, reader_on: community) }
  let_it_be(:collection_editor, refind: true) { FactoryBot.create(:user, editor_on: collection) }

  let(:manager) { community_manager }
  let(:editor) { community_editor }
  let(:reader) { community_reader }
end

RSpec.shared_context "depositing authorization testing" do
  include_context "entity authorization testing"

  let_it_be(:submission_target, refind: true) do
    collection.fetch_submission_target!.tap do |st|
      st.configure!(schema_versions: [item_schema_version], deposit_mode: :direct)
      st.transition_to! :open
    end
  end

  let_it_be(:reviewer, refind: true) do
    FactoryBot.create(:user, reviewer_on: collection)
  end

  let_it_be(:submitter, refind: true) do
    FactoryBot.create(:user, depositor_on: collection)
  end

  let_it_be(:submission, refind: true) do
    FactoryBot.create(:submission,
      submission_target:,
      schema_version: item_schema_version,
      parent_entity: collection,
      user: submitter,
      title: "Test Submission"
    )
  end
end

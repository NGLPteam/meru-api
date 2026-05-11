# frozen_string_literal: true

RSpec.describe Resolvers::ItemResolver, type: :resolver do
  let_it_be(:item_schema_version, refind: true) { FactoryBot.create(:schema_version, :item) }
  let_it_be(:community) { FactoryBot.create :community }
  let_it_be(:collection) { FactoryBot.create :collection, community: }

  let_it_be(:other_collection) { FactoryBot.create :collection, community: }

  let_it_be(:community_manager) { FactoryBot.create :user, manager_on: community }

  let_it_be(:editor) { FactoryBot.create :user, editor_on: collection }

  let_it_be(:reviewer) { FactoryBot.create :user, reviewer_on: collection }

  let_it_be(:depositor) { FactoryBot.create :user, depositor_on: collection }

  let_it_be(:item) { FactoryBot.create :item, collection:, title: "Public Item" }
  let_it_be(:hidden_item) { FactoryBot.create :item, :hidden, collection:, title: "Hidden Item" }
  let_it_be(:other_item) { FactoryBot.create :item, collection: other_collection, title: "Other Public Item" }

  let_it_be(:submission_target, refind: true) do
    collection.fetch_submission_target!.tap do |st|
      st.configure!(schema_versions: [item_schema_version], deposit_mode: :direct)
      st.transition_to! :open
    end
  end

  let_it_be(:submission, refind: true) do
    FactoryBot.create(:submission,
      submission_target:,
      schema_version: item_schema_version,
      parent_entity: collection,
      user: depositor,
      title: "Test Submission"
    )
  end

  let(:global_item_count) { 4 }
  let(:global_unfiltered_item_count) { 4 }

  let(:scoped_item_count) { 3 }

  let(:public_item_count) { 2 }

  let(:base_visible_count) { global_item_count }

  let(:expected_readable_count) { expected_readable_included_records.size }
  let(:expected_readable_unfiltered_count) { base_visible_count }
  let(:expected_updatable_count) { expected_count }
  let(:expected_updatable_unfiltered_count) { base_visible_count }

  let(:expected_readable_included_records) { [] }
  let(:expected_updatable_included_records) { [] }
  let(:expected_readable_excluded_records) { [] }
  let(:expected_updatable_excluded_records) { [] }

  let_it_be(:submission_draft_item, refind: true) { submission.entity }

  let_filter_arg!(:include_drafts) { false }

  include_examples "common resolver tests"

  shared_examples_for "optionally including drafts" do
    context "when filter includeDrafts: true" do
      let_filter_arg!(:include_drafts) { true }

      let(:included_records) { [submission_draft_item] }
      let(:excluded_records) { [] }

      let(:expected_count) { global_item_count }

      include_examples "a full resolution"
    end
  end

  shared_examples_for "scoped readability: granted" do
    context "when specifying access: READ_ONLY" do
      let_graphql_argument!(:access) { "READ_ONLY" }

      let(:included_records) { expected_readable_included_records }
      let(:excluded_records) { expected_readable_excluded_records }
      let(:expected_count) { expected_readable_count }
      let(:expected_unfiltered_count) { base_visible_count }

      include_examples "a full resolution"
    end
  end

  shared_examples_for "scoped readability: denied" do
    context "when specifying access: READ_ONLY" do
      let_graphql_argument!(:access) { "READ_ONLY" }

      let(:included_records) { [] }
      let(:excluded_records) { [item, hidden_item, other_item, submission_draft_item] }
      let(:expected_count) { 0 }
      let(:expected_unfiltered_count) { base_visible_count }

      include_examples "a full resolution"
    end
  end

  shared_examples_for "scoped updatability: granted" do
    context "when specifying access: UPDATE" do
      let_graphql_argument!(:access) { "UPDATE" }

      let(:included_records) { expected_updatable_included_records }
      let(:excluded_records) { expected_updatable_excluded_records }
      let(:expected_count) { expected_updatable_count }
      let(:expected_unfiltered_count) { expected_updatable_unfiltered_count }

      include_examples "a full resolution"
    end
  end

  shared_examples_for "scoped updatability: denied" do
    context "when specifying access: UPDATE" do
      let_graphql_argument!(:access) { "UPDATE" }

      let(:included_records) { [] }
      let(:excluded_records) { [item, hidden_item, other_item, submission_draft_item] }
      let(:expected_count) { 0 }
      let(:expected_unfiltered_count) { base_visible_count }

      include_examples "a full resolution"
    end
  end

  shared_examples_for "full visibility" do
    let(:included_records) { [item, hidden_item, other_item] }
    let(:excluded_records) { [submission_draft_item] }
    let(:expected_count) { included_records.size }
    let(:expected_unfiltered_count) { global_item_count }

    let(:expected_readable_included_records) { [item, hidden_item, other_item] }
    let(:expected_readable_excluded_records) { [submission_draft_item] }
    let(:expected_readable_count) { expected_readable_included_records.size }
    let(:expected_updatable_included_records) { [item, hidden_item, other_item] }
    let(:expected_updatable_excluded_records) { [submission_draft_item] }
    let(:expected_updatable_count) { expected_updatable_included_records.size }

    include_examples "a full resolution"
    include_examples "optionally including drafts"
  end

  shared_examples_for "scoped visibility" do
    let(:base_visible_count) { global_item_count }
    let(:included_records) { [item, other_item, hidden_item] }
    let(:excluded_records) { [submission_draft_item] }
    let(:expected_count) { included_records.size }
    let(:expected_unfiltered_count) { global_item_count }

    let(:expected_readable_included_records) { [item, hidden_item] }
    let(:expected_readable_excluded_records) { [other_item, submission_draft_item] }
    let(:expected_readable_count) { expected_readable_included_records.size }

    let(:expected_updatable_included_records) { [item, hidden_item] }
    let(:expected_updatable_excluded_records) { [other_item, submission_draft_item] }
    let(:expected_updatable_count) { expected_updatable_included_records.size }

    include_examples "a full resolution"
    include_examples "optionally including drafts"
  end

  shared_examples_for "public item visibility only" do
    let(:base_visible_count) { public_item_count }
    let(:included_records) { [item, other_item] }
    let(:expected_count) { public_item_count }
    let(:expected_unfiltered_count) { public_item_count }

    include_examples "a full resolution"
  end

  shared_examples_for "an empty result" do
    let(:excluded_records) { [item, hidden_item, other_item, submission_draft_item] }
    let(:expected_count) { 0 }
    let(:expected_unfiltered_count) { 0 }

    include_examples "a full resolution"
  end

  context "when no object is provided" do
    let(:object) { nil }

    as_an_admin_user do
      it_behaves_like "an empty result"
    end

    as_a_regular_user do
      it_behaves_like "an empty result"
    end

    as_an_anonymous_user do
      it_behaves_like "an empty result"
    end
  end

  context "against a community's items" do
    let(:object) { community }

    as_an_admin_user do
      it_behaves_like "full visibility" do
        include_examples "scoped readability: granted"
        include_examples "scoped updatability: granted"
      end
    end

    as_a_regular_user do
      context "as a community manager" do
        let(:current_user) { community_manager }

        it_behaves_like "full visibility" do
          include_examples "scoped readability: granted"

          include_examples "scoped updatability: granted"
        end
      end

      context "as an editor" do
        let(:current_user) { editor }

        it_behaves_like "scoped visibility" do
          include_examples "scoped readability: granted"

          include_examples "scoped updatability: granted"
        end
      end

      context "as a reviewer" do
        let(:current_user) { reviewer }

        it_behaves_like "scoped visibility" do
          include_examples "scoped readability: granted"

          include_examples "scoped updatability: denied"
        end
      end

      context "as a depositor" do
        let(:current_user) { depositor }

        it_behaves_like "scoped visibility" do
          include_examples "scoped readability: granted"

          context "when specifying includeDrafts: true" do
            let_filter_arg!(:include_drafts) { true }

            let(:expected_updatable_included_records) { [submission_draft_item] }
            let(:expected_updatable_excluded_records) { [item, hidden_item, other_item] }
            let(:expected_updatable_count) { 1 }

            include_examples "scoped updatability: granted"
          end
        end
      end

      context "with no special permissions" do
        it_behaves_like "public item visibility only" do
          include_examples "scoped readability: denied"
          include_examples "scoped updatability: denied"
        end
      end
    end

    as_an_anonymous_user do
      it_behaves_like "public item visibility only" do
        include_examples "scoped readability: denied"
        include_examples "scoped updatability: denied"
      end
    end
  end
end

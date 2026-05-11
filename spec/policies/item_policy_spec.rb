# frozen_string_literal: true

RSpec.describe ItemPolicy, type: :policy do
  include_context "policy setup"

  let_it_be(:community, refind: true) { FactoryBot.create(:community) }

  let_it_be(:collection, refind: true) { FactoryBot.create(:collection, community:) }

  let_it_be(:other_community, refind: true) { FactoryBot.create(:community) }

  let_it_be(:other_collection, refind: true) { FactoryBot.create(:collection, community: other_community) }

  let_it_be(:item_schema_version, refind: true) { FactoryBot.create(:schema_version, :item) }

  let_it_be(:submission_target, refind: true) do
    collection.fetch_submission_target!.tap do |st|
      st.configure!(schema_versions: [item_schema_version], deposit_mode: :direct)
      st.transition_to! :open
    end
  end

  let_it_be(:reviewer, refind: true) do
    FactoryBot.create(:user).tap do |user|
      FactoryBot.create(:submission_target_reviewer, submission_target:, user:)
    end.reload
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

  let_it_be(:submission_item, refind: true) { submission.entity }

  let_it_be(:item, refind: true) { FactoryBot.create :item, collection:, title: "Item" }

  let_it_be(:subitem, refind: true) { FactoryBot.create :item, parent: item, collection:, title: "Subitem" }

  let_it_be(:hidden_item, refind: true) { FactoryBot.create :item, :hidden, collection:, title: "Hidden Item" }

  let_it_be(:other_item, refind: true) { FactoryBot.create :item, collection: other_collection, title: "Other Item" }

  let_it_be(:contextual_role) { FactoryBot.create :role, :all_contextual }

  let(:record) { item }

  shared_examples_for "a rule that requires privileges" do
    succeed "as an admin" do
      let(:user) { admin }
    end

    context "as a user with all contextual permissions" do
      before { grant_access! contextual_role, on: item, to: user }

      succeed "on an item"

      succeed "on a subitem" do
        let(:record) { subitem }
      end

      failed "on an unrelated item" do
        let(:record) { other_item }
      end
    end

    failed "as a random user with no permissions"

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  shared_examples_for "a rule that requires admin privileges" do
    succeed "as an admin" do
      let(:user) { admin }
    end

    context "as a user with all contextual permissions" do
      before { grant_access! contextual_role, on: item, to: user }

      failed "on an item"

      failed "on a subitem" do
        let(:record) { subitem }
      end

      failed "on an unrelated item" do
        let(:record) { other_item }
      end
    end

    failed "as a random user with no permissions"

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  shared_examples_for "a rule that requires no special privileges" do
    succeed "as an admin" do
      let(:user) { admin }
    end

    context "as a user with all contextual permissions" do
      before { grant_access! contextual_role, on: item, to: user }

      succeed "on an item"

      succeed "on a subitem" do
        let(:record) { subitem }
      end

      succeed "on an unrelated item" do
        let(:record) { other_item }
      end
    end

    succeed "as a random user with no permissions"

    succeed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  shared_examples_for "a rule that requires privileges to interact with a hidden entity" do
    context "when the item is hidden" do
      let(:record) { hidden_item }

      succeed "as an admin" do
        let(:user) { admin }
      end

      succeed "as a user with all contextual permissions" do
        before { grant_access! contextual_role, on: hidden_item, to: user }
      end

      failed "as a random user" do
        let(:user) { regular_user }
      end

      failed "as an anonymous user" do
        let(:user) { anonymous_user }
      end
    end
  end

  shared_examples_for "a rule that requires depositor or reviewer privileges for submission drafts" do
    context "when the item is a submission draft" do
      let(:record) { submission_item }

      succeed "as an admin" do
        let(:user) { admin }
      end

      succeed "as the submitter" do
        let(:user) { submitter }
      end

      succeed "as a reviewer" do
        let(:user) { reviewer }
      end

      failed "as a random user" do
        let(:user) { regular_user }
      end

      failed "as an anonymous user" do
        let(:user) { anonymous_user }
      end
    end
  end

  shared_examples_for "a rule that requires depositor privileges for submission drafts" do
    context "when the item is a submission draft" do
      let(:record) { submission_item }

      succeed "as an admin" do
        let(:user) { admin }
      end

      succeed "as the submitter" do
        let(:user) { submitter }
      end

      failed "as a reviewer" do
        let(:user) { reviewer }
      end

      failed "as a random user" do
        let(:user) { regular_user }
      end

      failed "as an anonymous user" do
        let(:user) { anonymous_user }
      end
    end
  end

  shared_examples_for "a rule that requires reviewer privileges for submission drafts" do
    context "when the item is a submission draft" do
      let(:record) { submission_item }

      succeed "as an admin" do
        let(:user) { admin }
      end

      failed "as the submitter" do
        let(:user) { submitter }
      end

      succeed "as a reviewer" do
        let(:user) { reviewer }
      end

      failed "as a random user" do
        let(:user) { regular_user }
      end

      failed "as an anonymous user" do
        let(:user) { anonymous_user }
      end
    end
  end

  shared_examples_for "a rule that is prohibited for submission drafts" do
    context "when the item is a submission draft" do
      let(:record) { submission_item }

      failed "as an admin" do
        let(:user) { admin }
      end

      failed "as the submitter" do
        let(:user) { submitter }
      end

      failed "as a random user"

      failed "as an anonymous user" do
        let(:user) { anonymous_user }
      end
    end
  end

  describe_rule :read? do
    it_behaves_like "a rule that requires privileges"
    it_behaves_like "a rule that requires privileges to interact with a hidden entity"
    it_behaves_like "a rule that requires depositor or reviewer privileges for submission drafts"
  end

  describe_rule :show? do
    it_behaves_like "a rule that requires no special privileges"
    it_behaves_like "a rule that requires privileges to interact with a hidden entity"
    it_behaves_like "a rule that requires depositor or reviewer privileges for submission drafts"
  end

  describe_rule :create? do
    it_behaves_like "a rule that requires privileges"
  end

  describe_rule :update? do
    it_behaves_like "a rule that requires privileges"
    it_behaves_like "a rule that requires depositor privileges for submission drafts"
  end

  describe_rule :destroy? do
    it_behaves_like "a rule that requires privileges"
    it_behaves_like "a rule that is prohibited for submission drafts"
  end

  describe_rule :create_items? do
    it_behaves_like "a rule that requires privileges"
    it_behaves_like "a rule that is prohibited for submission drafts"
  end

  describe_rule :manage_access? do
    it_behaves_like "a rule that requires admin privileges"
  end

  describe_rule :alter_schema_version? do
    it_behaves_like "a rule that requires privileges"

    it_behaves_like "a rule that is prohibited for submission drafts"
  end

  describe_rule :deposit? do
    it_behaves_like "a rule that requires depositor privileges for submission drafts"
  end

  describe_rule :reparent? do
    it_behaves_like "a rule that requires privileges"

    it_behaves_like "a rule that is prohibited for submission drafts"
  end

  describe_rule :review? do
    it_behaves_like "a rule that requires reviewer privileges for submission drafts"
  end

  describe "relation scope" do
    let(:target) { Item.all }

    subject { policy.apply_scope(target, type: :active_record_relation) }

    context "as an admin" do
      let(:user) { admin }

      it "includes everything" do
        is_expected.to include item, subitem, other_item, submission_item
      end
    end

    context "as a user with all contextual permissions" do
      before do
        grant_access! contextual_role, on: item, to: user

        subitem.update!(visibility: :hidden)

        other_item.update!(visibility: :hidden)
      end

      it "includes the record the user has been assigned" do
        is_expected.to include(item)
      end

      it "includes hidden records within the user's purview" do
        is_expected.to include(subitem)
      end

      it "excludes hidden records outside the user's purview", :aggregate_failures do
        is_expected.to exclude(other_item)
        is_expected.to exclude(hidden_item)
      end

      it "excludes unpublished records the user does not have access to" do
        is_expected.to exclude(submission_item)
      end
    end

    context "as a reviewer" do
      let(:user) { reviewer }

      it "includes submission drafts under the reviewer's purview" do
        is_expected.to include(submission_item)
      end
    end

    context "as a submitter" do
      let(:user) { submitter }

      it "includes the submitter's submission drafts" do
        is_expected.to include(submission_item)
      end
    end

    context "as a random user" do
      before { other_item.update!(visibility: :hidden) }

      it "excludes hidden records" do
        is_expected.to exclude(other_item).and include(item, subitem)
      end

      it "excludes unpublished records" do
        is_expected.to exclude(submission_item)
      end
    end

    context "as an anonymous user" do
      let(:user) { anonymous_user }

      before { other_item.update!(visibility: :hidden) }

      it "excludes hidden records" do
        is_expected.to exclude(other_item).and include(item, subitem)
      end

      it "excludes unpublished records" do
        is_expected.to exclude(submission_item)
      end
    end
  end
end

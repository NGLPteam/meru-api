# frozen_string_literal: true

RSpec.describe ContributorUserLinkPolicy, type: :policy do
  let_it_be(:community, refind: true) { FactoryBot.create :community }

  let_it_be(:manager_role) { FactoryBot.create :role, :manager }

  let_it_be(:editor_role) { FactoryBot.create :role, :editor }

  let_it_be(:manager, refind: true) do
    FactoryBot.create(:user).tap do |user|
      grant_access! manager_role, on: community, to: user
    end
  end

  let_it_be(:editor, refind: true) do
    FactoryBot.create(:user).tap do |user|
      grant_access! editor_role, on: community, to: user
    end
  end

  let_it_be(:contributor, refind: true) { FactoryBot.create :contributor, :person }

  let_it_be(:linked_user, refind: true) { FactoryBot.create :user }

  let_it_be(:contributor_user_link, refind: true) { FactoryBot.create :contributor_user_link, :primary, contributor:, user: linked_user }

  let_it_be(:other_contributor_user_link, refind: true) { FactoryBot.create :contributor_user_link }

  let(:record) { contributor_user_link }

  shared_examples_for "a rule that requires access to either the contributor or the user" do |rule|
    succeed "as an admin" do
      let(:user) { admin }
    end

    succeed "as a manager" do
      let(:user) { manager }
    end

    succeed "as an editor" do
      let(:user) { editor }
    end

    succeed "as the linked user" do
      let(:user) { linked_user }
    end

    succeed "as a regular user" do
      let(:user) { regular_user }
    end

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  shared_examples_for "a prohibited rule" do
    failed "as an admin" do
      let(:user) { admin }
    end

    failed "as a manager" do
      let(:user) { manager }
    end

    failed "as an editor" do
      let(:user) { editor }
    end

    failed "as a regular user" do
      let(:user) { regular_user }
    end

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  shared_examples_for "a rule that requires destroy access" do
    succeed "as an admin" do
      let(:user) { admin }
    end

    succeed "as a manager" do
      let(:user) { manager }
    end

    failed "as an editor" do
      let(:user) { editor }
    end

    failed "as the linked user" do
      let(:user) { linked_user }
    end

    failed "as a regular user" do
      let(:user) { regular_user }
    end

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe_rule :read? do
    it_behaves_like "a rule that requires access to either the contributor or the user"
  end

  describe_rule :show? do
    it_behaves_like "a rule that requires access to either the contributor or the user"
  end

  describe_rule :create? do
    it_behaves_like "a prohibited rule"
  end

  describe_rule :update? do
    it_behaves_like "a prohibited rule"
  end

  describe_rule :destroy? do
    it_behaves_like "a rule that requires destroy access"
  end

  describe "relation scope" do
    let(:target) { ContributorUserLink.all }

    subject { policy.apply_scope(target, type: :active_record_relation) }

    shared_examples_for "all records" do
      it "includes everything" do
        is_expected.to include record, other_contributor_user_link
      end
    end

    shared_examples_for "no records" do
      it "includes nothing" do
        is_expected.to be_empty
      end
    end

    context "as an admin" do
      let(:user) { admin }

      include_examples "all records"
    end

    context "as a manager" do
      let(:user) { manager }

      include_examples "all records"
    end

    context "as an editor" do
      let(:user) { editor }

      include_examples "all records"
    end

    context "as the linked user" do
      let(:user) { linked_user }

      it "includes linked records" do
        is_expected.to include record
      end

      it "excludes unlinked records" do
        is_expected.to exclude other_contributor_user_link
      end
    end

    context "as a regular user" do
      let(:user) { regular_user }

      include_examples "no records"
    end

    context "as an anonymous user" do
      let(:user) { anonymous_user }

      include_examples "no records"
    end
  end
end

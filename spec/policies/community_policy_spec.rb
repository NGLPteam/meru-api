# frozen_string_literal: true

RSpec.describe CommunityPolicy, type: :policy do
  include_context "policy setup"

  let_it_be(:community, refind: true) { FactoryBot.create :community, title: "Community" }

  let_it_be(:other_community, refind: true) { FactoryBot.create :community, title: "Other Community" }

  let_it_be(:manager_role, refind: true) { Role.fetch :manager }

  let(:record) { community }

  describe_rule :show? do
    succeed "as an admin" do
      let(:user) { admin }
    end

    context "as a manager on the community" do
      before { grant_access! manager_role, on: community, to: user }

      succeed "on own community"

      succeed "on other communities" do
        let(:record) { other_community }
      end
    end

    succeed "as a user with no special access"

    succeed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe_rule :read? do
    succeed "as an admin" do
      let(:user) { admin }
    end

    context "as a manager on the community" do
      before { grant_access! manager_role, on: community, to: user }

      succeed "on own community"

      failed "on other communities" do
        let(:record) { other_community }
      end
    end

    failed "as a user with no special access"

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe_rule :create? do
    succeed "as an admin" do
      let(:user) { admin }
    end

    context "as a manager on the community" do
      before { grant_access! manager_role, on: community, to: user }

      failed "on the community"
    end

    failed "as a user with no special access"

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe_rule :update? do
    succeed "as an admin" do
      let(:user) { admin }
    end

    context "as a manager on the community" do
      before { grant_access! manager_role, on: community, to: user }

      succeed "on own community"

      failed "on other communities" do
        let(:record) { other_community }
      end
    end

    failed "as a user with no special access"

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe_rule :destroy? do
    succeed "as an admin" do
      let(:user) { admin }
    end

    context "as a manager on the community" do
      before { grant_access! manager_role, on: community, to: user }

      failed "on the community"
    end

    failed "as a user with no special access"

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe_rule :create_items? do
    succeed "as an admin" do
      let(:user) { admin }
    end

    context "as a manager on the community" do
      before { grant_access! manager_role, on: community, to: user }

      succeed "on own community"

      failed "on other communities" do
        let(:record) { other_community }
      end
    end

    failed "as a user with no special access"

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe_rule :create_collections? do
    succeed "as an admin" do
      let(:user) { admin }
    end

    context "as a manager on the community" do
      before { grant_access! manager_role, on: community, to: user }

      succeed "on own community"

      failed "on other communities" do
        let(:record) { other_community }
      end
    end

    failed "as a user with no special access"

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe "relation scope" do
    let(:target) { Community.all }

    subject { policy.apply_scope(target, type: :active_record_relation) }

    context "as an admin" do
      let(:user) { admin }

      it "includes everything" do
        is_expected.to include community, other_community
      end
    end

    context "as a manager on the community" do
      before { grant_access! manager_role, on: community, to: user }

      it "includes everything" do
        is_expected.to include community, other_community
      end
    end

    context "as a user with no special access" do
      it "includes all communities" do
        is_expected.to include community, other_community
      end
    end

    context "as an anonymous user" do
      let(:user) { anonymous_user }

      it "includes all communities" do
        is_expected.to include community, other_community
      end
    end
  end
end

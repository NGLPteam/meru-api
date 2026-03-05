# frozen_string_literal: true

RSpec.describe AccessGrantPolicy, type: :policy do
  include_context "policy setup"

  let_it_be(:community, refind: true) { FactoryBot.create :community }

  let_it_be(:manager, refind: true) { FactoryBot.create :user, manager_on: [community] }

  let_it_be(:editor, refind: true) { FactoryBot.create :user, editor_on: [community] }

  let_it_be(:admin_access_grant, refind: true) { admin.access_grants.where(accessible: community, role: Role.fetch(:admin)).first! }

  let_it_be(:manager_access_grant, refind: true) { manager.access_grants.where(role: Role.fetch(:manager)).first! }

  let_it_be(:editor_access_grant, refind: true) { editor.access_grants.where(role: Role.fetch(:editor)).first! }

  let_it_be(:other_access_grant, refind: true) { FactoryBot.create :access_grant }

  let(:record) { editor_access_grant }

  describe_rule :read? do
    succeed "as an admin on manager grants" do
      let(:user) { admin }
      let(:record) { manager_access_grant }
    end

    succeed "as an admin on editor grants" do
      let(:user) { admin }
      let(:record) { editor_access_grant }
    end

    succeed "as a manager on own grants" do
      let(:user) { manager }
      let(:record) { manager_access_grant }
    end

    succeed "as a manager on editor grants" do
      let(:user) { manager }
      let(:record) { editor_access_grant }
    end

    failed "as an editor" do
      let(:user) { editor }
      let(:record) { editor_access_grant }
    end

    failed "as a regular user" do
      let(:user) { regular_user }
    end

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe_rule :show? do
    succeed "as an admin on manager grants" do
      let(:user) { admin }
      let(:record) { manager_access_grant }
    end

    succeed "as an admin on editor grants" do
      let(:user) { admin }
      let(:record) { editor_access_grant }
    end

    succeed "as a manager on own grants" do
      let(:user) { manager }
      let(:record) { manager_access_grant }
    end

    succeed "as a manager on editor grants" do
      let(:user) { manager }
      let(:record) { editor_access_grant }
    end

    failed "as an editor" do
      let(:user) { editor }
      let(:record) { editor_access_grant }
    end

    failed "as a regular user" do
      let(:user) { regular_user }
    end

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe_rule :create? do
    context "as an admin" do
      let(:user) { admin }

      failed "on admin access grants" do
        let(:record) { admin_access_grant }
      end

      succeed "on manager grants" do
        let(:record) { manager_access_grant }
      end

      succeed "on editor grants" do
        let(:record) { editor_access_grant }
      end
    end

    context "as a manager" do
      let(:user) { manager }

      failed "on admin access grants" do
        let(:record) { admin_access_grant }
      end

      failed "on self grants" do
        let(:record) { manager_access_grant }
      end

      succeed "on editor grants" do
        let(:record) { editor_access_grant }
      end
    end

    failed "as an editor" do
      let(:user) { editor }
      let(:record) { editor_access_grant }
    end

    failed "as a regular user" do
      let(:user) { regular_user }
    end

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe_rule :update? do
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

  describe_rule :manage_access? do
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

  describe_rule :destroy? do
    context "as an admin" do
      let(:user) { admin }

      failed "on admin access grants" do
        let(:record) { admin_access_grant }
      end

      succeed "on manager grants" do
        let(:record) { manager_access_grant }
      end

      succeed "on editor grants" do
        let(:record) { editor_access_grant }
      end
    end

    context "as a manager" do
      let(:user) { manager }

      failed "on admin access grants" do
        let(:record) { admin_access_grant }
      end

      failed "on own manager role" do
        let(:record) { manager_access_grant }
      end

      succeed "on editor grants" do
        let(:record) { editor_access_grant }
      end
    end

    failed "as an editor" do
      let(:user) { editor }
      let(:record) { editor_access_grant }
    end

    failed "as a regular user" do
      let(:user) { regular_user }
    end

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe "relation scope" do
    let(:target) { AccessGrant.all }

    subject { policy.apply_scope(target, type: :active_record_relation) }

    context "as an admin" do
      let(:user) { admin }

      it "includes all grants" do
        is_expected.to match_array AccessGrant.all.to_a
      end
    end

    context "as a manager" do
      let(:user) { manager }

      it "includes own grant" do
        is_expected.to include manager_access_grant
      end

      it "includes editor grant" do
        is_expected.to include editor_access_grant
      end

      it "excludes other grants" do
        is_expected.to exclude other_access_grant
      end
    end

    context "as an editor" do
      let(:user) { editor }

      it "is empty" do
        is_expected.to be_blank
      end
    end

    context "as a regular user" do
      let(:user) { regular_user }

      it "is empty" do
        is_expected.to be_blank
      end
    end

    context "as an anonymous user" do
      let(:user) { anonymous_user }

      it "is empty" do
        is_expected.to be_blank
      end
    end
  end
end

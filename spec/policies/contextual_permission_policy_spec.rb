# frozen_string_literal: true

RSpec.describe ContextualPermissionPolicy, type: :policy do
  include_context "policy setup"

  let_it_be(:community, refind: true) { FactoryBot.create :community }

  let!(:contextual_permission) do
    if user.anonymous?
      ContextualPermission.empty_permission_for(user, community)
    else
      ContextualPermission.find_by(hierarchical: community, user:) || ContextualPermission.empty_permission_for(user, community)
    end
  end

  let(:record) { contextual_permission }

  describe_rule :read? do
    succeed "as an admin" do
      let(:user) { admin }
    end

    succeed "as a regular user" do
      let(:user) { regular_user }
    end

    succeed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe_rule :show? do
    succeed "as an admin" do
      let(:user) { admin }
    end

    succeed "as a regular user" do
      let(:user) { regular_user }
    end

    succeed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe_rule :create? do
    failed "as an admin" do
      let(:user) { admin }
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

    failed "as a regular user" do
      let(:user) { regular_user }
    end

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe_rule :destroy? do
    failed "as an admin" do
      let(:user) { admin }
    end

    failed "as a regular user" do
      let(:user) { regular_user }
    end

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end
end

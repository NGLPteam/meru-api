# frozen_string_literal: true

RSpec.describe GlobalConfigurationPolicy, type: :policy do
  include_context "policy setup"

  let!(:record) { GlobalConfiguration.fetch }

  describe_rule :show? do
    succeed "as an admin" do
      let(:user) { admin }
    end

    succeed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe_rule :create? do
    failed "as an admin" do
      let(:user) { admin }
    end

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe_rule :update? do
    succeed "as an admin" do
      let(:user) { admin }
    end

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe_rule :destroy? do
    failed "as an admin" do
      let(:user) { admin }
    end

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe "relation scope" do
    let(:target) { GlobalConfiguration.all }

    subject { policy.apply_scope(target, type: :active_record_relation) }

    context "as an admin" do
      let(:user) { admin }

      it "includes the record" do
        is_expected.to include record
      end
    end

    context "as an anonymous user" do
      let(:user) { anonymous_user }

      it "includes the record" do
        is_expected.to include record
      end
    end
  end
end

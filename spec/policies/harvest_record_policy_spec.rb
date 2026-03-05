# frozen_string_literal: true

RSpec.describe HarvestRecordPolicy, type: :policy do
  include_context "policy setup"

  let_it_be(:harvest_record) { FactoryBot.create :harvest_record }

  let(:record) { harvest_record }

  describe_rule :read? do
    succeed "as an admin" do
      let(:user) { admin }
    end

    failed "as a regular user"

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe_rule :create? do
    failed "as an admin" do
      let(:user) { admin }
    end

    failed "as a regular user"

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe_rule :update? do
    succeed "as an admin" do
      let(:user) { admin }
    end

    failed "as a regular user"

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe_rule :destroy? do
    succeed "as an admin" do
      let(:user) { admin }
    end

    failed "as a regular user"

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end
end

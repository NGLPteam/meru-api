# frozen_string_literal: true

RSpec.describe HarvestMappingPolicy, type: :policy do
  include_context "policy setup"

  let_it_be(:harvest_mapping) { FactoryBot.create :harvest_mapping }

  let(:record) { harvest_mapping }

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
    succeed "as an admin" do
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

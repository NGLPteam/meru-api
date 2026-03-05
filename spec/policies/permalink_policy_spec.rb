# frozen_string_literal: true

RSpec.describe PermalinkPolicy, type: :policy do
  include_context "policy setup"

  let_it_be(:permalink) { FactoryBot.create :permalink }

  let(:record) { permalink }

  describe_rule :read? do
    succeed "as an admin" do
      let(:user) { admin }
    end

    succeed "as a regular user"

    succeed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe_rule :show? do
    succeed "as an admin" do
      let(:user) { admin }
    end

    succeed "as a regular user"

    succeed "as an anonymous user" do
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

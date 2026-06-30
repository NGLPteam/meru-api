# frozen_string_literal: true

RSpec.describe UserPolicy, type: :policy do
  include_context "entity authorization testing"

  let_it_be(:other_users, refind: true) { FactoryBot.create_list :user, 2 }

  let_it_be(:other_user, refind: true) { other_users.first }

  let(:record) { other_user }

  shared_examples_for "user read access" do
    succeed "as an admin on another user" do
      let(:user) { admin }
    end

    succeed "as an admin on self" do
      let(:user) { admin }
      let(:record) { admin }
    end

    succeed "as a manager on another user" do
      let(:user) { manager }
    end

    succeed "as a manager on self" do
      let(:user) { manager }
      let(:record) { manager }
    end

    succeed "as an editor on another user" do
      let(:user) { editor }
    end

    succeed "as an editor on self" do
      let(:user) { editor }
      let(:record) { editor }
    end

    succeed "as a reader on another user" do
      let(:user) { reader }
    end

    succeed "as a reader on self" do
      let(:user) { reader }
      let(:record) { reader }
    end

    succeed "as a regular user on another user"

    succeed "as a regular user on self" do
      let(:record) { regular_user }
    end

    failed "as an anonymous user on another user" do
      let(:user) { anonymous_user }
    end

    succeed "as an anonymous user on self" do
      let(:user) { anonymous_user }
      let(:record) { anonymous_user }
    end
  end

  shared_examples_for "an admin or self action" do
    succeed "as an admin on another user" do
      let(:user) { admin }
    end

    succeed "as an admin on self" do
      let(:user) { admin }
      let(:record) { admin }
    end

    failed "as a manager on another user" do
      let(:user) { manager }
    end

    succeed "as a manager on self" do
      let(:user) { manager }
      let(:record) { manager }
    end

    failed "as an editor on another user" do
      let(:user) { editor }
    end

    succeed "as an editor on self" do
      let(:user) { editor }
      let(:record) { editor }
    end

    failed "as a reader on another user" do
      let(:user) { reader }
    end

    succeed "as a reader on self" do
      let(:user) { reader }
      let(:record) { reader }
    end

    failed "as a regular user on another user"

    succeed "as a regular user on self" do
      let(:record) { regular_user }
    end

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe_rule :read? do
    include_examples "user read access"
  end

  describe_rule :show? do
    include_examples "user read access"
  end

  describe_rule :create? do
    include_examples "a forbidden permission"
  end

  describe_rule :update? do
    include_examples "an admin or self action"
  end

  describe_rule :destroy? do
    include_examples "a forbidden permission"
  end

  describe_rule :reset_password? do
    include_examples "an admin or self action"
  end

  describe "relation scope" do
    include_context "policy scope setup"

    let(:target) { User.all }

    shared_examples_for "a scope that sees all users" do
      include_records! :user, :admin_user, :other_users, :regular_user, :manager, :editor, :reader

      include_examples "a scope that includes known records"
    end

    shared_examples_for "a scope that only sees the current user" do
      include_records! :user

      include_examples "a scope that includes known records"
    end

    context "as an admin" do
      let(:user) { admin_user }

      include_examples "a scope that sees all users"
    end

    context "as a manager" do
      let(:user) { manager }

      include_examples "a scope that sees all users"
    end

    context "as an editor" do
      let(:user) { editor }

      include_examples "a scope that only sees the current user"
    end

    context "as a reader" do
      let(:user) { reader }

      include_examples "a scope that only sees the current user"
    end

    context "as a regular user" do
      let(:user) { regular_user }

      include_examples "a scope that only sees the current user"
    end

    context "as an anonymous user" do
      let(:user) { anonymous_user }

      it "is empty" do
        is_expected.to be_blank
      end
    end
  end
end

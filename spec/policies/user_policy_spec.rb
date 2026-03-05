# frozen_string_literal: true

RSpec.describe UserPolicy, type: :policy do
  include_context "policy setup"

  let_it_be(:community, refind: true) { FactoryBot.create :community }

  let_it_be(:manager, refind: true) { FactoryBot.create :user, manager_on: [community] }

  let_it_be(:editor, refind: true) { FactoryBot.create :user, editor_on: [community] }

  let_it_be(:reader, refind: true) { FactoryBot.create :user, reader_on: [community] }

  let_it_be(:other_users, refind: true) { FactoryBot.create_list :user, 2 }

  let_it_be(:other_user, refind: true) { other_users.first }

  let(:record) { other_user }

  describe_rule :read? do
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

    failed "as an anonymous user on another user" do
      let(:user) { anonymous_user }
    end

    succeed "as an anonymous user on self" do
      let(:user) { anonymous_user }
      let(:record) { anonymous_user }
    end
  end

  describe_rule :show? do
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

    failed "as an anonymous user on another user" do
      let(:user) { anonymous_user }
    end

    succeed "as an anonymous user on self" do
      let(:user) { anonymous_user }
      let(:record) { anonymous_user }
    end
  end

  describe_rule :create? do
    failed "as an admin" do
      let(:user) { admin }
    end

    failed "as a manager" do
      let(:user) { manager }
    end

    failed "as an editor" do
      let(:user) { editor }
    end

    failed "as a reader" do
      let(:user) { reader }
    end

    failed "as a regular user"

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe_rule :update? do
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

  describe_rule :destroy? do
    failed "as an admin" do
      let(:user) { admin }
    end

    failed "as a manager" do
      let(:user) { manager }
    end

    failed "as an editor" do
      let(:user) { editor }
    end

    failed "as a reader" do
      let(:user) { reader }
    end

    failed "as a regular user"

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe_rule :reset_password? do
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

  describe "relation scope" do
    let(:target) { User.all }

    subject { policy.apply_scope(target, type: :active_record_relation) }

    context "as an admin" do
      let(:user) { admin }

      it "includes everything" do
        is_expected.to include admin, *other_users
      end
    end

    context "as a manager" do
      let(:user) { manager }

      it "includes everything" do
        is_expected.to include manager, *other_users
      end
    end

    context "as an editor" do
      let(:user) { editor }

      it "includes only the user" do
        is_expected.to contain_exactly editor
      end
    end

    context "as a reader" do
      let(:user) { reader }

      it "includes only the user" do
        is_expected.to contain_exactly reader
      end
    end

    context "as a regular user" do
      it "includes only the user" do
        is_expected.to contain_exactly regular_user
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

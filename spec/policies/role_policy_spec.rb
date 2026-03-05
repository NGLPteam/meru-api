# frozen_string_literal: true

RSpec.describe RolePolicy, type: :policy do
  include_context "policy setup"

  let_it_be(:community, refind: true) { FactoryBot.create :community }

  let_it_be(:manager, refind: true) { FactoryBot.create :user, manager_on: [community] }

  let_it_be(:editor, refind: true) { FactoryBot.create :user, editor_on: [community] }

  let_it_be(:reader, refind: true) { FactoryBot.create :user, reader_on: [community] }

  let_it_be(:role_admin, refind: true) { Role.fetch(:admin) }

  let_it_be(:role_manager, refind: true) { Role.fetch(:manager) }

  let_it_be(:role_editor, refind: true) { Role.fetch(:editor) }

  let_it_be(:role_reader, refind: true) { Role.fetch(:reader) }

  let_it_be(:role_custom, refind: true) do
    FactoryBot.create :role, name: "AA", custom_priority: 100
  end

  let(:record) { role_custom }

  before do
    AssignableRoleTarget.refresh!
  end

  describe_rule :show? do
    succeed "as an admin" do
      let(:user) { admin }
    end

    succeed "as a manager" do
      let(:user) { manager }
    end

    succeed "as an editor" do
      let(:user) { editor }
    end

    succeed "as a reader" do
      let(:user) { reader }
    end

    succeed "as a regular user"

    succeed "as an anonymous user" do
      let(:user) { anonymous_user }
    end

    context "on system roles" do
      succeed "admin role" do
        let(:user) { anonymous_user }
        let(:record) { role_admin }
      end

      succeed "manager role" do
        let(:user) { anonymous_user }
        let(:record) { role_manager }
      end

      succeed "editor role" do
        let(:user) { anonymous_user }
        let(:record) { role_editor }
      end

      succeed "reader role" do
        let(:user) { anonymous_user }
        let(:record) { role_reader }
      end
    end
  end

  describe_rule :read? do
    context "as an admin" do
      let(:user) { admin }

      succeed "on custom roles"

      succeed "on admin role" do
        let(:record) { role_admin }
      end

      succeed "on manager role" do
        let(:record) { role_manager }
      end

      succeed "on editor role" do
        let(:record) { role_editor }
      end

      succeed "on reader role" do
        let(:record) { role_reader }
      end
    end

    context "as a manager" do
      let(:user) { manager }

      succeed "on custom roles"

      succeed "on admin role" do
        let(:record) { role_admin }
      end

      succeed "on manager role" do
        let(:record) { role_manager }
      end

      succeed "on editor role" do
        let(:record) { role_editor }
      end

      succeed "on reader role" do
        let(:record) { role_reader }
      end
    end

    context "as an editor" do
      let(:user) { editor }

      succeed "on custom roles"

      succeed "on admin role" do
        let(:record) { role_admin }
      end

      succeed "on manager role" do
        let(:record) { role_manager }
      end

      succeed "on editor role" do
        let(:record) { role_editor }
      end

      succeed "on reader role" do
        let(:record) { role_reader }
      end
    end

    context "as a reader" do
      let(:user) { reader }

      succeed "on custom roles"

      succeed "on admin role" do
        let(:record) { role_admin }
      end

      succeed "on manager role" do
        let(:record) { role_manager }
      end

      succeed "on editor role" do
        let(:record) { role_editor }
      end

      succeed "on reader role" do
        let(:record) { role_reader }
      end
    end

    context "as a regular user" do
      succeed "on custom roles"

      succeed "on admin role" do
        let(:record) { role_admin }
      end

      succeed "on manager role" do
        let(:record) { role_manager }
      end

      succeed "on editor role" do
        let(:record) { role_editor }
      end

      succeed "on reader role" do
        let(:record) { role_reader }
      end
    end

    context "as an anonymous user" do
      let(:user) { anonymous_user }

      succeed "on custom roles"

      succeed "on admin role" do
        let(:record) { role_admin }
      end

      succeed "on manager role" do
        let(:record) { role_manager }
      end

      succeed "on editor role" do
        let(:record) { role_editor }
      end

      succeed "on reader role" do
        let(:record) { role_reader }
      end
    end
  end

  describe_rule :create? do
    context "as an admin" do
      let(:user) { admin }

      succeed "on custom roles"

      failed "on admin role" do
        let(:record) { role_admin }
      end
      failed "on manager role" do
        let(:record) { role_manager }
      end
      failed "on editor role" do
        let(:record) { role_editor }
      end
      failed "on reader role" do
        let(:record) { role_reader }
      end
    end

    context "as a manager" do
      let(:user) { manager }

      failed "on custom roles"
      failed "on system roles" do
        let(:record) { role_admin }
      end
    end

    context "as an editor" do
      let(:user) { editor }

      failed "on custom roles"
      failed "on system roles" do
        let(:record) { role_admin }
      end
    end

    context "as a reader" do
      let(:user) { reader }

      failed "on custom roles"
      failed "on system roles" do
        let(:record) { role_admin }
      end
    end

    context "as a regular user" do
      failed "on custom roles"
      failed "on system roles" do
        let(:record) { role_admin }
      end
    end

    context "as an anonymous user" do
      let(:user) { anonymous_user }

      failed "on custom roles"
      failed "on system roles" do
        let(:record) { role_admin }
      end
    end
  end

  describe_rule :update? do
    context "as an admin" do
      let(:user) { admin }

      succeed "on custom roles"

      failed "on admin role" do
        let(:record) { role_admin }
      end
      failed "on manager role" do
        let(:record) { role_manager }
      end
      failed "on editor role" do
        let(:record) { role_editor }
      end
      failed "on reader role" do
        let(:record) { role_reader }
      end
    end

    context "as a manager" do
      let(:user) { manager }

      failed "on custom roles"
      failed "on system roles" do
        let(:record) { role_admin }
      end
    end

    context "as an editor" do
      let(:user) { editor }

      failed "on custom roles"
      failed "on system roles" do
        let(:record) { role_admin }
      end
    end

    context "as a reader" do
      let(:user) { reader }

      failed "on custom roles"
      failed "on system roles" do
        let(:record) { role_admin }
      end
    end

    context "as a regular user" do
      failed "on custom roles"
      failed "on system roles" do
        let(:record) { role_admin }
      end
    end

    context "as an anonymous user" do
      let(:user) { anonymous_user }

      failed "on custom roles"
      failed "on system roles" do
        let(:record) { role_admin }
      end
    end
  end

  describe_rule :destroy? do
    context "as an admin" do
      let(:user) { admin }

      succeed "on custom roles"

      failed "on admin role" do
        let(:record) { role_admin }
      end
      failed "on manager role" do
        let(:record) { role_manager }
      end
      failed "on editor role" do
        let(:record) { role_editor }
      end
      failed "on reader role" do
        let(:record) { role_reader }
      end
    end

    context "as a manager" do
      let(:user) { manager }

      failed "on custom roles"
      failed "on system roles" do
        let(:record) { role_admin }
      end
    end

    context "as an editor" do
      let(:user) { editor }

      failed "on custom roles"

      failed "on system roles" do
        let(:record) { role_admin }
      end
    end

    context "as a reader" do
      let(:user) { reader }

      failed "on custom roles"

      failed "on system roles" do
        let(:record) { role_admin }
      end
    end

    context "as a regular user" do
      failed "on custom roles"

      failed "on system roles" do
        let(:record) { role_admin }
      end
    end

    context "as an anonymous user" do
      let(:user) { anonymous_user }

      failed "on custom roles"

      failed "on system roles" do
        let(:record) { role_admin }
      end
    end
  end

  describe_rule :assign? do
    context "as an admin" do
      let(:user) { admin }

      failed "on admin role" do
        let(:record) { role_admin }
      end

      succeed "on manager role" do
        let(:record) { role_manager }
      end

      succeed "on editor role" do
        let(:record) { role_editor }
      end

      succeed "on reader role" do
        let(:record) { role_reader }
      end

      succeed "on custom roles"
    end

    context "as a manager" do
      let(:user) { manager }

      failed "on admin role" do
        let(:record) { role_admin }
      end

      failed "on manager role" do
        let(:record) { role_manager }
      end

      succeed "on editor role" do
        let(:record) { role_editor }
      end

      succeed "on reader role" do
        let(:record) { role_reader }
      end

      succeed "on custom roles"
    end

    context "as an editor" do
      let(:user) { editor }

      failed "on custom roles"

      failed "on admin role" do
        let(:record) { role_admin }
      end

      failed "on manager role" do
        let(:record) { role_manager }
      end

      failed "on editor role" do
        let(:record) { role_editor }
      end

      failed "on reader role" do
        let(:record) { role_reader }
      end
    end

    context "as a reader" do
      let(:user) { reader }

      failed "on custom roles"

      failed "on admin role" do
        let(:record) { role_admin }
      end

      failed "on manager role" do
        let(:record) { role_manager }
      end

      failed "on editor role" do
        let(:record) { role_editor }
      end

      failed "on reader role" do
        let(:record) { role_reader }
      end
    end

    context "as a regular user" do
      failed "on custom roles"

      failed "on admin role" do
        let(:record) { role_admin }
      end

      failed "on manager role" do
        let(:record) { role_manager }
      end

      failed "on editor role" do
        let(:record) { role_editor }
      end

      failed "on reader role" do
        let(:record) { role_reader }
      end
    end

    context "as an anonymous user" do
      let(:user) { anonymous_user }

      failed "on custom roles"

      failed "on admin role" do
        let(:record) { role_admin }
      end

      failed "on manager role" do
        let(:record) { role_manager }
      end

      failed "on editor role" do
        let(:record) { role_editor }
      end

      failed "on reader role" do
        let(:record) { role_reader }
      end
    end
  end

  describe "relation scope" do
    let(:target) { Role.all }

    subject { policy.apply_scope(target, type: :active_record_relation) }

    context "as an admin" do
      let(:user) { admin }

      it "includes everything" do
        is_expected.to match_array Role.all.to_a
      end
    end

    context "as a manager" do
      let(:user) { manager }

      it "includes everything" do
        is_expected.to match_array Role.all.to_a
      end
    end

    context "as a regular user" do
      it "includes everything" do
        is_expected.to match_array Role.all.to_a
      end
    end

    context "as an anonymous user" do
      let(:user) { anonymous_user }

      it "includes everything" do
        is_expected.to match_array Role.all.to_a
      end
    end
  end
end

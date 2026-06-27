# frozen_string_literal: true

RSpec.describe PrimaryRoleAssignment, type: :model, grants_access: true do
  include_context "entity authorization testing"

  let(:user) { regular_user }

  subject(:primary_role_assignment) { user.reload_primary_role_assignment }

  shared_context "with editor grant" do
    before do
      grant_access!(role_editor, on: collection, to: user)
    end
  end

  shared_context "with author grant" do
    before do
      grant_access!(role_author, on: item, to: user)
    end
  end

  context "as an admin user" do
    let(:user) { admin_user }

    context "when the admin is also an author" do
      include_context "with author grant"

      it "returns the admin role as the primary role" do
        expect(primary_role_assignment.role).to eq role_admin
      end
    end
  end

  context "as a regular user" do
    context "with no grants" do
      it "returns nil" do
        expect(primary_role_assignment).to be_nil
      end
    end

    context "with an editor grant on a collection" do
      include_context "with editor grant"

      it "returns the editor role as the primary role" do
        expect(primary_role_assignment.role).to eq role_editor
      end
    end

    context "with an author grant on an item" do
      include_context "with author grant"

      it "returns the author role as the primary role" do
        expect(primary_role_assignment.role).to eq role_author
      end
    end
  end

  context "as an anonymous user" do
    let(:user) { anonymous_user }
    let(:primary_role_assignment) { nil }

    it { is_expected.to be_nil }
  end
end

# frozen_string_literal: true

RSpec.describe User, type: :model do
  let_it_be(:entity, refind: true) { FactoryBot.create :community }
  let_it_be(:manager, refind: true) { FactoryBot.create :user, manager_on: entity }
  let_it_be(:editor, refind: true) { FactoryBot.create :user, editor_on: entity }
  let_it_be(:reader, refind: true) { FactoryBot.create :user, reader_on: entity }
  let_it_be(:admin, refind: true) { FactoryBot.create :user, :admin }
  let_it_be(:user, refind: true) { FactoryBot.create :user }

  subject { user }

  shared_examples_for "common assigned actions" do
    it { is_expected.to have_allowed_action "roles.read" }
  end

  shared_examples_for "someone who can modify communities" do
    it { is_expected.to have_allowed_action "communities.create" }
    it { is_expected.to have_allowed_action "communities.update" }
    it { is_expected.to have_allowed_action "communities.delete" }
  end

  shared_examples_for "someone who cannot modify communities" do
    it { is_expected.not_to have_allowed_action "communities.create" }
    it { is_expected.not_to have_allowed_action "communities.update" }
    it { is_expected.not_to have_allowed_action "communities.delete" }
  end

  shared_examples_for "someone with global community access" do
    it { is_expected.to have_allowed_action("communities.read") }

    it_behaves_like "someone who can modify communities"
  end

  shared_examples_for "someone with no global community access" do
    it { is_expected.not_to have_allowed_action("communities.read") }

    it_behaves_like "someone who cannot modify communities"
  end

  shared_examples_for "someone who can modify roles" do
    it { is_expected.to have_allowed_action "roles.create" }
    it { is_expected.to have_allowed_action "roles.update" }
    it { is_expected.to have_allowed_action "roles.delete" }
  end

  shared_examples_for "someone who cannot modify roles" do
    it { is_expected.not_to have_allowed_action "roles.create" }
    it { is_expected.not_to have_allowed_action "roles.update" }
    it { is_expected.not_to have_allowed_action "roles.delete" }
  end

  shared_examples_for "someone who can modify users" do
    it { is_expected.to have_allowed_action "users.create" }
    it { is_expected.to have_allowed_action "users.update" }
    it { is_expected.to have_allowed_action "users.delete" }
  end

  shared_examples "someone who cannot modify users" do
    it { is_expected.not_to have_allowed_action "users.create" }
    it { is_expected.not_to have_allowed_action "users.update" }
    it { is_expected.not_to have_allowed_action "users.delete" }
  end

  shared_examples "someone with no user access" do
    it { is_expected.not_to have_allowed_action "users.read" }

    it_behaves_like "someone who cannot modify users"
  end

  shared_examples "someone who can view contributors" do
    it { is_expected.to have_allowed_action "contributors.read" }
  end

  shared_examples "someone who can create or update contributors" do
    it { is_expected.to have_allowed_action "contributors.create" }
    it { is_expected.to have_allowed_action "contributors.update" }

    it_behaves_like "someone who can view contributors"
  end

  shared_examples "someone who can modify contributors" do
    it { is_expected.to have_allowed_action "contributors.delete" }

    it_behaves_like "someone who can create or update contributors"
  end

  shared_examples_for "someone with admin access" do
    it { is_expected.to have_allowed_action "admin.access" }
  end

  shared_examples_for "someone with no admin access" do
    it { is_expected.not_to have_allowed_action "admin.access" }
  end

  context "as an admin" do
    subject { admin }

    it { is_expected.to have_allowed_action "settings.update" }

    include_examples "common assigned actions"

    it_behaves_like "someone with admin access"
    it_behaves_like "someone with global community access"
    it_behaves_like "someone who can modify contributors"
    it_behaves_like "someone who can modify roles"
    it_behaves_like "someone who can modify users"
  end

  context "with a contextual role" do
    context "as a manager" do
      subject { manager }

      it { is_expected.not_to have_allowed_action "settings.update" }

      include_examples "common assigned actions"

      it_behaves_like "someone with admin access"
      it_behaves_like "someone who can modify contributors"
      it_behaves_like "someone who cannot modify roles"
      it_behaves_like "someone who cannot modify users"
      it_behaves_like "someone with no global community access"
    end

    context "as an editor" do
      subject { editor }

      it { is_expected.not_to have_allowed_action "contributors.delete" }
      it { is_expected.not_to have_allowed_action "settings.update" }

      include_examples "common assigned actions"

      it_behaves_like "someone with admin access"
      it_behaves_like "someone who can create or update contributors"

      it_behaves_like "someone who cannot modify roles"
      it_behaves_like "someone with no user access"
      it_behaves_like "someone with no global community access"
    end

    context "as a reader" do
      subject { reader }

      it { is_expected.not_to have_allowed_action "contributors.delete" }
      it { is_expected.not_to have_allowed_action "settings.update" }

      include_examples "common assigned actions"

      it_behaves_like "someone who can view contributors"
      it_behaves_like "someone who cannot modify roles"
      it_behaves_like "someone with no admin access"
      it_behaves_like "someone with no user access"
      it_behaves_like "someone with no global community access"
    end
  end

  context "as a user with no special assignments" do
    subject { user }

    include_examples "common assigned actions"

    it { is_expected.not_to have_allowed_action "contributors.read" }

    it_behaves_like "someone who cannot modify roles"
    it_behaves_like "someone with no admin access"
    it_behaves_like "someone with no user access"
    it_behaves_like "someone with no global community access"
  end
end

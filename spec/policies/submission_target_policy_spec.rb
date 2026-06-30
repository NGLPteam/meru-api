# frozen_string_literal: true

RSpec.describe SubmissionTargetPolicy, type: :policy do
  include_context "depositing policy setup"

  let(:record) { submission_target }

  describe_rule :read? do
    include_examples "a full-access depositing permission"
  end

  describe_rule :show? do
    include_examples "a full-access depositing permission"
  end

  describe_rule :deposit? do
    include_examples "an admin+submitter-only permission"
  end

  describe_rule :manage_reviewers? do
    include_examples "an admin-only depositing permission"
  end

  describe_rule :publish? do
    include_examples "an admin-only depositing permission"
  end

  describe_rule :request_deposit_access? do
    include_examples "a permission denied to admin users"
    include_examples "a permission granted to authenticated users"
    include_examples "a permission denied to submitters"

    succeed "as a reviewer (with no deposit access)" do
      let(:user) { reviewer }
    end

    failed "as a regular user who already has a deposit request" do
      let(:user) { regular_user }

      before do
        FactoryBot.create(:depositor_request, submission_target:, user:)
      end
    end

    failed "as a regular user when the target is closed" do
      let(:user) { regular_user }

      before do
        submission_target.transition_to! :closed
      end
    end
  end

  describe_rule :reset_all_agreements? do
    include_examples "an admin-only depositing permission"
  end

  describe_rule :review? do
    include_examples "an admin+reviewer-only permission"
  end

  describe_rule :create? do
    include_examples "a forbidden depositing permission"
  end

  describe_rule :update? do
    include_examples "an admin-only depositing permission"
  end

  describe_rule :destroy? do
    include_examples "a forbidden depositing permission"
  end

  describe "relation scope", policy_scope: true do
    include_context "depositing policy scope setup"

    let(:target) { SubmissionTarget.all }

    let_it_be(:hidden_collection, refind: true) { FactoryBot.create :collection, :hidden, community:, title: "Hidden Collection" }

    let_it_be(:hidden_target, refind: true) { hidden_collection.fetch_submission_target! }

    let_it_be(:community_reviewer, refind: true) { FactoryBot.create :user, reviewer_on: community }
    let_it_be(:community_depositor, refind: true) { FactoryBot.create :user, depositor_on: community }

    shared_examples_for "a scope that sees the hidden target" do
      include_records! :hidden_target

      include_examples "a scope that includes known records"
    end

    shared_examples_for "a scope that only sees public targets" do
      exclude_records! :hidden_target

      include_examples "a scope that includes known records"
    end

    include_records! :submission_target

    context "as an admin" do
      let(:user) { admin_user }

      include_examples "a scope that sees the hidden target"
    end

    context "as a reviewer with access" do
      let(:user) { community_reviewer }

      include_examples "a scope that sees the hidden target"
    end

    context "as a reviewer without access" do
      let(:user) { reviewer }

      include_examples "a scope that only sees public targets"
    end

    context "as a depositor with access" do
      let(:user) { community_depositor }

      include_examples "a scope that sees the hidden target"
    end

    context "as a depositor without access" do
      let(:user) { submitter }

      include_examples "a scope that only sees public targets"
    end

    context "as a regular user" do
      let(:user) { regular_user }

      include_examples "a scope that only sees public targets"
    end

    context "as an anonymous user" do
      let(:user) { anonymous_user }

      exclude_records! :submission_target, :hidden_target

      include_examples "a scope that includes known records"
    end
  end
end

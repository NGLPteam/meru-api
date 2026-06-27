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

  describe "relation scope" do
    include_context "policy scope setup"

    let(:target) { SubmissionTarget.all }

    context "as an admin" do
      let(:user) { admin }

      it "includes everything" do
        is_expected.to include record
      end
    end

    context "as a regular user" do
      it "includes accessible records" do
        is_expected.to include(record)
      end
    end

    context "as an anonymous user" do
      let(:user) { anonymous_user }

      it "includes accessible records" do
        is_expected.to include(record)
      end
    end
  end
end

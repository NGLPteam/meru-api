# frozen_string_literal: true

RSpec.describe SubmissionBatchPublicationPolicy, :depositing_policy, type: :policy do
  let_it_be(:submission_batch_publication, refind: true) { FactoryBot.create :submission_batch_publication, submission_target: }

  let(:record) { submission_batch_publication }

  describe_rule :read? do
    include_examples "an admin+reviewer+submitter-only permission"
  end

  describe_rule :show? do
    include_examples "an admin+reviewer+submitter-only permission"
  end

  describe_rule :create? do
    include_examples "a forbidden depositing permission"
  end

  describe_rule :update? do
    include_examples "a forbidden depositing permission"
  end

  describe_rule :destroy? do
    include_examples "a forbidden depositing permission"
  end

  describe "relation scope", :depositing_policy_scope do
    let(:target) { SubmissionBatchPublication.all }

    include_records! :submission_batch_publication

    context "as an admin" do
      let(:user) { admin }

      include_examples "a scope that includes known records"
    end

    context "as a reviewer" do
      let(:user) { reviewer }

      include_examples "a scope that includes known records"
    end

    context "as the submitter" do
      let(:user) { submitter }

      include_examples "a scope that includes known records"
    end

    context "as a regular user" do
      let(:user) { regular_user }

      include_examples "a scope that excludes known records"
    end

    context "as an anonymous user" do
      let(:user) { anonymous_user }

      include_examples "a scope that excludes known records"
    end
  end
end

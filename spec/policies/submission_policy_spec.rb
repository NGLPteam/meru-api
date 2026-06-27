# frozen_string_literal: true

RSpec.describe SubmissionPolicy, type: :policy do
  include_context "depositing policy setup"

  let(:record) { submission }

  describe_rule :read? do
    include_examples "an admin+reviewer+submitter-only permission"
  end

  describe_rule :show? do
    include_examples "an admin+reviewer+submitter-only permission"
  end

  describe_rule :create? do
    include_examples "an admin-only depositing permission"

    succeed "as a submitter who has accepted the agreement" do
      let(:user) { submitter }

      before do
        submission_target.accept_agreement_for!(user)
      end
    end
  end

  describe_rule :update? do
    include_examples "an admin+submitter-only permission"
  end

  describe_rule :destroy? do
    include_examples "an admin+submitter-only permission"
  end

  describe_rule :alter_schema_version? do
    include_examples "an admin-only depositing permission"
  end

  describe_rule :comment? do
    include_examples "an admin+reviewer+submitter-only permission"
  end

  describe_rule :migrate? do
    include_examples "an admin-only depositing permission"
  end

  describe_rule :publish? do
    include_examples "an admin-only depositing permission"
  end

  describe_rule :request_review? do
    include_examples "an admin+reviewer+submitter-only permission"
  end

  describe_rule :review? do
    include_examples "an admin+reviewer-only permission"
  end

  describe "relation scope" do
    let(:target) { Submission.all }

    subject { policy.apply_scope(target, type: :active_record_relation) }

    context "as an admin" do
      let(:user) { admin }

      it "includes everything" do
        is_expected.to include record
      end
    end

    context "as a reviewer" do
      let(:user) { reviewer }

      it "includes accessible records" do
        is_expected.to include(record)
      end
    end

    context "as the submitter" do
      let(:user) { submitter }

      it "includes accessible records" do
        is_expected.to include(record)
      end
    end

    context "as a regular user" do
      it "includes accessible records" do
        is_expected.to exclude(record)
      end
    end

    context "as an anonymous user" do
      let(:user) { anonymous_user }

      it "includes accessible records" do
        is_expected.to exclude(record)
      end
    end
  end
end

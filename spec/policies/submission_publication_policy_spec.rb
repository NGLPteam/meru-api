# frozen_string_literal: true

RSpec.describe SubmissionPublicationPolicy, type: :policy do
  include_context "depositing policy setup"

  let_it_be(:submission_publication, refind: true) { FactoryBot.create :submission_publication, submission: }

  let(:record) { submission_publication }

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

  describe "relation scope" do
    let(:target) { SubmissionPublication.all }

    subject { policy.apply_scope(target, type: :active_record_relation) }

    context "as an admin" do
      let(:user) { admin }

      it "includes everything" do
        is_expected.to include record
      end
    end

    context "as a reviewer" do
      let(:user) { reviewer }

      it "includes everything" do
        is_expected.to include record
      end
    end

    context "as the submitter" do
      let(:user) { submitter }

      it "includes everything" do
        is_expected.to include record
      end
    end

    context "as a regular user" do
      it "forbids access" do
        is_expected.to exclude(record)
      end
    end

    context "as an anonymous user" do
      let(:user) { anonymous_user }

      it "forbids access" do
        is_expected.to exclude(record)
      end
    end
  end
end

# frozen_string_literal: true

RSpec.describe SubmissionPolicy, type: :policy do
  include_context "policy setup"

  let_it_be(:community, refind: true) { FactoryBot.create(:community) }

  let_it_be(:collection, refind: true) { FactoryBot.create(:collection, community:) }

  let_it_be(:item_schema_version, refind: true) { FactoryBot.create(:schema_version, :item) }

  let_it_be(:submission_target, refind: true) do
    collection.fetch_submission_target!.tap do |st|
      st.configure!(schema_versions: [item_schema_version], deposit_mode: :direct)
      st.transition_to! :open
    end
  end

  let_it_be(:reviewer, refind: true) do
    FactoryBot.create(:user).tap do |user|
      FactoryBot.create(:submission_target_reviewer, submission_target:, user:)
    end.reload
  end

  let_it_be(:submitter, refind: true) do
    FactoryBot.create(:user, depositor_on: collection)
  end

  let_it_be(:submission, refind: true) do
    FactoryBot.create(:submission,
      submission_target:,
      schema_version: item_schema_version,
      parent_entity: collection,
      user: submitter,
      title: "Test Submission"
    )
  end

  let(:record) { submission }

  shared_examples_for "admin + reviewer + submitter access" do
    succeed "as an admin" do
      let(:user) { admin }
    end

    succeed "as a reviewer" do
      let(:user) { reviewer }
    end

    succeed "as the submitter" do
      let(:user) { submitter }
    end

    failed "as a regular user" do
      let(:user) { regular_user }
    end

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  shared_examples_for "admin + reviewer access" do
    succeed "as an admin" do
      let(:user) { admin }
    end

    succeed "as a reviewer" do
      let(:user) { reviewer }
    end

    failed "as the submitter" do
      let(:user) { submitter }
    end

    failed "as a regular user" do
      let(:user) { regular_user }
    end

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  shared_examples_for "admin-only access" do
    succeed "as an admin" do
      let(:user) { admin }
    end

    failed "as a reviewer" do
      let(:user) { reviewer }
    end

    failed "as the submitter" do
      let(:user) { submitter }
    end

    failed "as a regular user" do
      let(:user) { regular_user }
    end

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe_rule :read? do
    include_examples "admin + reviewer + submitter access"
  end

  describe_rule :show? do
    include_examples "admin + reviewer + submitter access"
  end

  describe_rule :create? do
    succeed "as an admin" do
      let(:user) { admin }
    end

    failed "as a reviewer" do
      let(:user) { reviewer }
    end

    failed "as the submitter" do
      let(:user) { submitter }
    end

    succeed "as a submitter who has accepted the agreement" do
      let(:user) { submitter }

      before do
        submission_target.accept_agreement_for!(user)
      end
    end

    failed "as a regular user" do
      let(:user) { regular_user }
    end

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe_rule :update? do
    succeed "as an admin" do
      let(:user) { admin }
    end

    failed "as a reviewer" do
      let(:user) { reviewer }
    end

    succeed "as the submitter" do
      let(:user) { submitter }
    end

    failed "as a regular user" do
      let(:user) { regular_user }
    end

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe_rule :destroy? do
    failed "as an admin" do
      let(:user) { admin }
    end

    failed "as a reviewer" do
      let(:user) { reviewer }
    end

    failed "as the submitter" do
      let(:user) { submitter }
    end

    failed "as a regular user" do
      let(:user) { regular_user }
    end

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe_rule :alter_schema_version? do
    include_examples "admin-only access"
  end

  describe_rule :comment? do
    include_examples "admin + reviewer + submitter access"
  end

  describe_rule :migrate? do
    include_examples "admin-only access"
  end

  describe_rule :publish? do
    include_examples "admin-only access"
  end

  describe_rule :request_review? do
    include_examples "admin + reviewer + submitter access"
  end

  describe_rule :review? do
    include_examples "admin + reviewer access"
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

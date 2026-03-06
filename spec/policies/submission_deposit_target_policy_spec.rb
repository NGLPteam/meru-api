# frozen_string_literal: true

RSpec.describe SubmissionDepositTargetPolicy, type: :policy do
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

  let_it_be(:submission_deposit_target, refind: true) { submission_target.submission_deposit_targets.first! }

  let(:record) { submission_deposit_target }

  describe_rule :read? do
    succeed "as an admin" do
      let(:user) { admin }
    end

    succeed "as a regular user" do
      let(:user) { regular_user }
    end

    succeed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe_rule :show? do
    succeed "as an admin" do
      let(:user) { admin }
    end

    succeed "as a regular user" do
      let(:user) { regular_user }
    end

    succeed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe_rule :deposit? do
    succeed "as an admin" do
      let(:user) { admin }
    end

    failed "as a regular user" do
      let(:user) { regular_user }
    end

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe_rule :create? do
    failed "as an admin" do
      let(:user) { admin }
    end

    failed "as a regular user" do
      let(:user) { regular_user }
    end

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe_rule :update? do
    failed "as an admin" do
      let(:user) { admin }
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

    failed "as a regular user" do
      let(:user) { regular_user }
    end

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe "relation scope" do
    let(:target) { SubmissionDepositTarget.all }

    subject { policy.apply_scope(target, type: :active_record_relation) }

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

# frozen_string_literal: true

RSpec.describe SubmissionReviewPolicy, :depositing_policy, type: :policy do
  let_it_be(:submission_review, refind: true) { FactoryBot.create :submission_review, submission: }

  let(:record) { submission_review }

  describe_rule :read? do
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

  describe_rule :show? do
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

  describe_rule :update? do
    failed "as an admin" do
      let(:user) { admin }
    end

    succeed "as the owner" do
      let(:user) { submission_review.user }
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

    succeed "as the owner" do
      let(:user) { submission_review.user }
    end

    failed "as a regular user" do
      let(:user) { regular_user }
    end

    failed "as an anonymous user" do
      let(:user) { anonymous_user }
    end
  end

  describe "relation scope", :depositing_policy_scope do
    let(:target) { SubmissionReview.all }

    include_records! :submission_review

    include_examples "a depositing scope"
  end
end

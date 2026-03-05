# frozen_string_literal: true

RSpec.describe Mutations::SubmissionTargetReviewerDestroy, type: :request, graphql: :mutation do
  mutation_query! <<~GRAPHQL
  mutation SubmissionTargetReviewerDestroy($input: SubmissionTargetReviewerDestroyInput!) {
    submissionTargetReviewerDestroy(input: $input) {
      destroyed
      destroyedId
      ... ErrorFragment
    }
  }
  GRAPHQL

  let_it_be(:collection, refind: true) { FactoryBot.create(:collection) }
  let_it_be(:submission_target, refind: true) { collection.fetch_submission_target! }
  let_it_be(:user, refind: true) { FactoryBot.create(:user) }

  let_it_be(:existing_submission_target_reviewer_attrs) do
    {
      submission_target:,
      user:,
    }
  end

  let_it_be(:existing_submission_target_reviewer) { FactoryBot.create(:submission_target_reviewer, **existing_submission_target_reviewer_attrs) }

  let_mutation_input!(:submission_target_reviewer_id) { existing_submission_target_reviewer.to_encoded_id }

  let(:valid_mutation_shape) do
    gql.mutation(:submission_target_reviewer_destroy) do |m|
      m[:destroyed] = true
      m[:destroyed_id] = be_an_encoded_id.of_a_deleted_model
    end
  end

  let(:empty_mutation_shape) do
    gql.empty_mutation :submission_target_reviewer_destroy
  end

  shared_examples_for "a successful mutation" do
    let(:expected_shape) { valid_mutation_shape }

    it "destroys the submission target reviewer" do
      expect_request! do |req|
        req.effect! change(SubmissionTargetReviewer, :count).by(-1)
        req.effect! change(AccessGrant, :count).by(-1)

        req.data! expected_shape
      end
    end
  end

  shared_examples_for "an unauthorized mutation" do
    let(:expected_shape) { empty_mutation_shape }

    it "is not authorized" do
      expect_request! do |req|
        req.effect! execute_safely
        req.effect! keep_the_same(SubmissionTargetReviewer, :count)

        req.unauthorized!

        req.data! expected_shape
      end
    end
  end

  as_an_admin_user do
    it_behaves_like "a successful mutation"
  end

  as_a_regular_user do
    it_behaves_like "an unauthorized mutation"
  end

  as_an_anonymous_user do
    it_behaves_like "an unauthorized mutation"
  end
end

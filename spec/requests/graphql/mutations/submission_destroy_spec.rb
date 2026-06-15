# frozen_string_literal: true

RSpec.describe Mutations::SubmissionDestroy, type: :request, graphql: :mutation do
  mutation_query! <<~GRAPHQL
  mutation SubmissionDestroy($input: SubmissionDestroyInput!) {
    submissionDestroy(input: $input) {
      destroyed
      destroyedId
      ... ErrorFragment
    }
  }
  GRAPHQL

  let_it_be(:existing_submission_attrs) do
    {}
  end

  let_it_be(:existing_submission, refind: true) { FactoryBot.create(:submission, **existing_submission_attrs) }

  let_mutation_input!(:submission_id) { existing_submission.to_encoded_id }

  let(:valid_mutation_shape) do
    gql.mutation(:submission_destroy) do |m|
      m[:destroyed] = true
      m[:destroyed_id] = be_an_encoded_id.of_a_deleted_model
    end
  end

  let(:empty_mutation_shape) do
    gql.empty_mutation :submission_destroy
  end

  let(:only_drafts_error_shape) do
    gql.mutation(:submission_destroy, no_only_drafts_errors: false) do |m|
      m[:destroyed] = nil
      m[:destroyed_id] = nil

      m.global_errors do |ge|
        ge.error :only_draft_submissions_destructible
      end
    end
  end

  shared_examples_for "a successful mutation" do
    let(:expected_shape) { valid_mutation_shape }

    it "destroys the submission" do
      expect_request! do |req|
        req.effect! change(Submission, :count).by(-1)

        req.data! expected_shape
      end
    end

    context "when the submission is not a draft" do
      before do
        existing_submission.transition_to! :submitted
      end

      it "fails to destroy the submission" do
        expect_request! do |req|
          req.effect! keep_the_same(Submission, :count)

          req.data! only_drafts_error_shape
        end
      end
    end
  end

  shared_examples_for "an unauthorized mutation" do
    let(:expected_shape) { empty_mutation_shape }

    it "is not authorized" do
      expect_request! do |req|
        req.effect! keep_the_same(Submission, :count)

        req.unauthorized!

        req.data! expected_shape
      end
    end
  end

  shared_examples_for "an authorized mutation" do
    include_examples "a successful mutation"
  end

  as_an_admin_user do
    include_examples "an authorized mutation"
  end

  context "as the owner of the submission" do
    let(:current_user) { existing_submission.user }

    include_examples "an authorized mutation"
  end

  as_a_regular_user do
    include_examples "an unauthorized mutation"
  end

  as_an_anonymous_user do
    include_examples "an unauthorized mutation"
  end
end

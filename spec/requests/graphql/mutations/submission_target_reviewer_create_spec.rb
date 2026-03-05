# frozen_string_literal: true

RSpec.describe Mutations::SubmissionTargetReviewerCreate, type: :request, graphql: :mutation do
  mutation_query! <<~GRAPHQL
  mutation SubmissionTargetReviewerCreate($input: SubmissionTargetReviewerCreateInput!) {
    submissionTargetReviewerCreate(input: $input) {
      submissionTargetReviewer {
        id
        slug

        submissionTarget {
          id

          canManageReviewers {
            ... AuthorizationResultFragment
          }
        }

        user {
          id
        }

      }
      ... ErrorFragment
    }
  }
  GRAPHQL

  let_it_be(:collection, refind: true) { FactoryBot.create(:collection) }
  let_it_be(:submission_target, refind: true) { collection.fetch_submission_target! }

  let_it_be(:user, refind: true) { FactoryBot.create(:user) }

  let_mutation_input!(:submission_target_id) { submission_target.to_encoded_id }
  let_mutation_input!(:user_id) { user.to_encoded_id }

  let(:valid_mutation_shape) do
    gql.mutation(:submission_target_reviewer_create) do |m|
      m.prop(:submission_target_reviewer) do |str|
        str[:id] = be_an_encoded_id.of_an_existing_model
        str[:slug] = be_an_encoded_slug

        str.prop :submission_target do |st|
          st[:id] = submission_target_id

          st.prop :can_manage_reviewers do |auth|
            auth[:value] = true
          end
        end

        str.prop :user do |u|
          u[:id] = user_id
        end
      end
    end
  end

  let(:empty_mutation_shape) do
    gql.empty_mutation :submission_target_reviewer_create
  end

  shared_examples_for "a successful mutation" do
    let(:expected_shape) { valid_mutation_shape }

    it "creates the submission target reviewer" do
      expect_request! do |req|
        req.effect! change(SubmissionTargetReviewer, :count).by(1)
        req.effect! change(AccessGrant, :count).by(1)

        req.data! expected_shape
      end
    end
  end

  shared_examples_for "an unauthorized mutation" do
    let(:expected_shape) { empty_mutation_shape }

    it "is not authorized" do
      expect_request! do |req|
        req.effect! keep_the_same(AccessGrant, :count)
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

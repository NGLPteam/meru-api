# frozen_string_literal: true

RSpec.describe Mutations::SubmissionRequestReview, type: :request, graphql: :mutation do
  mutation_query! <<~GRAPHQL
  mutation SubmissionRequestReview($input: SubmissionRequestReviewInput!) {
    submissionRequestReview(input: $input) {
      submission {
        id
      }

      submissionReview {
        state

        submission {
          id
        }

        user {
          id
        }

        canUpdate {
          ... AuthorizationResultFragment
        }

        canDestroy {
          ... AuthorizationResultFragment
        }
      }

      ... ErrorFragment
    }
  }
  GRAPHQL

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

  let_it_be(:reviewer) { FactoryBot.create(:user) }

  let_mutation_input!(:submission_id) { submission.to_encoded_id }

  let_mutation_input!(:user_id) { reviewer.to_encoded_id }

  let(:valid_mutation_shape) do
    gql.mutation(:submission_request_review) do |m|
      m.prop :submission do |s|
        s[:id] = submission_id
      end

      m.prop :submission_review do |sr|
        sr[:state] = "PENDING"

        sr.auth_results(can_update: false, can_destroy: false)

        sr.prop :submission do |s|
          s[:id] = submission_id
        end

        sr.prop :user do |u|
          u[:id] = user_id
        end
      end
    end
  end

  let(:empty_mutation_shape) do
    gql.empty_mutation :submission_request_review
  end

  shared_examples_for "a successful mutation" do
    let(:expected_shape) { valid_mutation_shape }

    it "request_reviews the submission" do
      expect_request! do |req|
        req.effect! change(SubmissionReview, :count).by(1)

        req.data! expected_shape
      end
    end
  end

  shared_examples_for "an unauthorized mutation" do
    let(:expected_shape) { empty_mutation_shape }

    it "is not authorized" do
      expect_request! do |req|
        req.effect! keep_the_same(SubmissionReview, :count)

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

  as_a_regular_user do
    include_examples "an unauthorized mutation"
  end

  as_an_anonymous_user do
    include_examples "an unauthorized mutation"
  end
end

# frozen_string_literal: true

RSpec.describe Mutations::SubmissionCommentCreate, type: :request, graphql: :mutation do
  mutation_query! <<~GRAPHQL
  mutation SubmissionCommentCreate($input: SubmissionCommentCreateInput!) {
    submissionCommentCreate(input: $input) {
      submissionComment {
        id
        slug
        role
        content

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

  let_mutation_input!(:submission_id) { submission.to_encoded_id }

  let_mutation_input!(:content) { "This is a comment." }

  let(:can_update) { true }
  let(:can_destroy) { true }

  let(:expected_role) do
    if current_user == submitter
      "SUBMITTER"
    else
      "REVIEWER"
    end
  end

  let(:valid_mutation_shape) do
    gql.mutation(:submission_comment_create) do |m|
      m.prop(:submission_comment) do |sc|
        sc[:id] = be_an_encoded_id.of_an_existing_model
        sc[:slug] = be_an_encoded_slug
        sc[:role] = expected_role
        sc[:content] = content

        sc.prop(:submission) do |s|
          s[:id] = submission_id
        end

        sc.prop(:user) do |u|
          u[:id] = current_user.to_encoded_id
        end

        sc.auth_results(can_update:, can_destroy:)
      end
    end
  end

  let(:empty_mutation_shape) do
    gql.empty_mutation :submission_comment_create
  end

  shared_examples_for "a successful mutation" do
    let(:expected_shape) { valid_mutation_shape }

    it "creates the submission comment" do
      expect_request! do |req|
        req.effect! change(SubmissionComment, :count).by(1)

        req.data! expected_shape
      end
    end
  end

  shared_examples_for "an unauthorized mutation" do
    let(:expected_shape) { empty_mutation_shape }

    it "is not authorized" do
      expect_request! do |req|
        req.effect! execute_safely
        req.effect! keep_the_same(SubmissionComment, :count)

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

    context "when the user is a depositor" do
      let(:current_user) { submitter }

      include_examples "an authorized mutation"
    end
  end

  as_an_anonymous_user do
    include_examples "an unauthorized mutation"
  end
end

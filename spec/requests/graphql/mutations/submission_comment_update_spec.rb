# frozen_string_literal: true

RSpec.describe Mutations::SubmissionCommentUpdate, type: :request, graphql: :mutation do
  mutation_query! <<~GRAPHQL
  mutation SubmissionCommentUpdate($input: SubmissionCommentUpdateInput!) {
    submissionCommentUpdate(input: $input) {
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

  let(:can_update) { current_user == submitter }
  let(:can_destroy) { true }

  let_it_be(:existing_submission_comment_attrs) do
    {
      submission:,
      user: submitter,
    }
  end

  let_it_be(:existing_submission_comment) { FactoryBot.create(:submission_comment, **existing_submission_comment_attrs) }

  let_mutation_input!(:submission_comment_id) { existing_submission_comment.to_encoded_id }

  let_mutation_input!(:content) { "This is a new comment." }

  let(:valid_mutation_shape) do
    gql.mutation(:submission_comment_update) do |m|
      m.prop(:submission_comment) do |sc|
        sc[:id] = be_an_encoded_id.of_an_existing_model
        sc[:slug] = be_an_encoded_slug
      end
    end
  end

  let(:empty_mutation_shape) do
    gql.empty_mutation :submission_comment_update
  end

  shared_examples_for "a successful mutation" do
    let(:expected_shape) { valid_mutation_shape }

    it "updates the submission comment" do
      expect_request! do |req|
        req.effect! keep_the_same(SubmissionComment, :count)

        req.data! expected_shape
      end
    end
  end

  shared_examples_for "an unauthorized mutation" do
    let(:expected_shape) { empty_mutation_shape }

    it "is not authorized" do
      expect_request! do |req|
        req.effect! execute_safely

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

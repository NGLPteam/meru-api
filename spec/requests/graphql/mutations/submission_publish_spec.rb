# frozen_string_literal: true

RSpec.describe Mutations::SubmissionPublish, type: :request, graphql: :mutation do
  mutation_query! <<~GRAPHQL
  mutation SubmissionPublish($input: SubmissionPublishInput!) {
    submissionPublish(input: $input) {
      submissionPublication {
        id
        state

        submission {
          id
          state
        }

        user {
          id
        }

        transitions {
          nodes {
            id
            fromState
            toState

            user {
              id
            }
          }
        }
      }

      submission {
        id
        state
      }

      entity {
        ... on Submittable {
          submissionStatus
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

  let_it_be(:approved_submission, refind: true) do
    FactoryBot.create(:submission,
      :approved,
      submission_target:,
      schema_version: item_schema_version,
      parent_entity: collection,
      title: "Test Approved Submission"
    )
  end

  let_it_be(:approved_entity, refind: true) { approved_submission.entity }

  let_it_be(:rejected_submission, refind: true) do
    FactoryBot.create(:submission,
      :rejected,
      submission_target:,
      schema_version: item_schema_version,
      parent_entity: collection,
      title: "Test Rejected Submission"
    )
  end

  let_it_be(:rejected_entity, refind: true) { rejected_submission.entity }

  let_mutation_input!(:submission_id) { approved_submission.to_encoded_id }

  let(:valid_mutation_shape) do
    gql.mutation(:submission_publish) do |m|
      m.prop :entity do |ent|
        ent[:submission_status] = "SUBMISSION_PUBLISHED"
      end

      m.prop :submission do |s|
        s[:id] = submission_id
        s[:state] = "PUBLISHED"
      end

      m.prop :submission_publication do |sp|
        sp[:state] = "SUCCESS"
      end
    end
  end

  let(:empty_mutation_shape) do
    gql.empty_mutation :submission_publish
  end

  shared_examples_for "a successful mutation" do
    let(:expected_shape) { valid_mutation_shape }

    it "publishes the submission" do
      expect_request! do |req|
        req.effect! change(SubmissionPublication, :count).by(1)
        req.effect! change(SubmissionPublicationTransition, :count).by(2)
        req.effect! change { approved_submission.current_state(force_reload: true) }.from("approved").to("published")
        req.effect! change { approved_entity.reload.submission_status }.from("submission_draft").to("submission_published")

        req.data! expected_shape
      end
    end

    context "when provided a submission that is not approved" do
      let_mutation_input!(:submission_id) { rejected_submission.to_encoded_id }

      let(:expected_shape) do
        gql.mutation(:submission_publish, no_errors: false) do |m|
          m[:entity] = be_blank
          m[:submission] = be_blank
          m[:submission_publication] = be_blank

          m.attribute_errors do |ae|
            ae.error :submission, :must_be_publishable
          end
        end
      end

      it "refuses to publish" do
        expect_request! do |req|
          req.effect! keep_the_same(SubmissionPublication, :count)
          req.effect! keep_the_same(SubmissionPublicationTransition, :count)
          req.effect! keep_the_same { rejected_submission.current_state(force_reload: true) }
          req.effect! keep_the_same { rejected_entity.reload.submission_status }

          req.data! expected_shape
        end
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
  end

  as_an_anonymous_user do
    include_examples "an unauthorized mutation"
  end
end

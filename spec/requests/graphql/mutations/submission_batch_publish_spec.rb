# frozen_string_literal: true

RSpec.describe Mutations::SubmissionBatchPublish, type: :request, graphql: :mutation do
  mutation_query! <<~GRAPHQL
  mutation SubmissionBatchPublish($input: SubmissionBatchPublishInput!) {
    submissionBatchPublish(input: $input) {
      submissionBatchPublication {
        id
        state

        publications {
          state

          submission {
            id
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

      submissionTarget {
        id
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

  let_it_be(:unaffiliated_submission, refind: true) do
    FactoryBot.create(:submission)
  end

  let(:submissions) { [approved_submission] }

  let_mutation_input!(:submission_target_id) { submission_target.to_encoded_id }

  let_mutation_input!(:submission_ids) { submissions.map(&:to_encoded_id) }

  let(:valid_mutation_shape) do
    gql.mutation(:submission_batch_publish) do |m|
      m.prop :submission_target do |st|
        st[:id] = submission_target_id
      end

      m.prop :submission_batch_publication do |sbp|
        sbp[:id] = be_an_encoded_id.of_an_existing_model
        sbp[:state] = "BATCHED"

        sbp.array :publications do |pubs|
          submissions.each do |sub|
            pubs.item do |pub|
              pub[:state] = "BATCHED"

              pub.prop :submission do |s|
                s[:id] = sub.to_encoded_id
              end

              pub.prop :user do |u|
                u[:id] = current_user.to_encoded_id
              end

              pub.prop :transitions do |trx|
                trx.array :nodes do |ns|
                  ns.item do |n|
                    n[:id] = be_an_encoded_id.of_an_existing_model

                    n[:from_state] = "PENDING"
                    n[:to_state] = "BATCHED"

                    n.prop :user do |u|
                      u[:id] = current_user.to_encoded_id
                    end
                  end

                  ns.item do |n|
                    n[:id] = be_an_encoded_id.of_an_existing_model

                    n[:from_state] = nil
                    n[:to_state] = "PENDING"

                    n.prop :user do |u|
                      u[:id] = current_user.to_encoded_id
                    end
                  end
                end
              end
            end
          end
        end

        sbp.prop :transitions do |trx|
          trx.array :nodes do |ns|
            ns.item do |n|
              n[:id] = be_an_encoded_id.of_an_existing_model

              n[:from_state] = "PENDING"
              n[:to_state] = "BATCHED"

              n.prop :user do |u|
                u[:id] = current_user.to_encoded_id
              end
            end

            ns.item do |n|
              n[:id] = be_an_encoded_id.of_an_existing_model

              n[:from_state] = nil
              n[:to_state] = "PENDING"

              n.prop :user do |u|
                u[:id] = current_user.to_encoded_id
              end
            end
          end
        end
      end
    end
  end

  let(:empty_mutation_shape) do
    gql.empty_mutation :submission_batch_publish
  end

  shared_examples_for "a successful mutation" do
    let(:expected_shape) { valid_mutation_shape }

    it "enqueues a batch publishing job for the provided submissions" do
      expect_request! do |req|
        req.effect! have_enqueued_job(SubmissionPublications::PublishJob).once
        req.effect! change(SubmissionBatchPublication, :count).by(1)
        req.effect! change(SubmissionPublication, :count).by(1)

        req.data! expected_shape
      end
    end

    context "when providing an unaffiliated submission" do
      let(:submissions) { [approved_submission, unaffiliated_submission] }

      let(:expected_shape) do
        gql.mutation(:submission_batch_publish, no_errors: false) do |m|
          m[:submission_batch_publication] = be_blank
          m[:submission_target] = be_blank

          m.attribute_errors do |ae|
            ae.error "submissions.1", :mismatched_batch_submission_target
          end
        end
      end

      it "refuses to enqueue" do
        expect_request! do |req|
          req.effect! have_enqueued_job(SubmissionPublications::PublishJob).exactly(0).times
          req.effect! keep_the_same(SubmissionBatchPublication, :count)
          req.effect! keep_the_same(SubmissionPublication, :count)

          req.data! expected_shape
        end
      end
    end

    context "when providing an unpublishable submission" do
      let(:submissions) { [approved_submission, rejected_submission] }

      let(:expected_shape) do
        gql.mutation(:submission_batch_publish, no_errors: false) do |m|
          m[:submission_batch_publication] = be_blank
          m[:submission_target] = be_blank

          m.attribute_errors do |ae|
            ae.error "submissions.1", :must_be_publishable
          end
        end
      end

      it "refuses to enqueue" do
        expect_request! do |req|
          req.effect! have_enqueued_job(SubmissionPublications::PublishJob).exactly(0).times
          req.effect! keep_the_same(SubmissionBatchPublication, :count)
          req.effect! keep_the_same(SubmissionPublication, :count)

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

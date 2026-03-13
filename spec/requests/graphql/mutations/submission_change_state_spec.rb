# frozen_string_literal: true

RSpec.describe Mutations::SubmissionChangeState, type: :request, graphql: :mutation, grants_access: true do
  mutation_query! <<~GRAPHQL
  mutation SubmissionChangeState($input: SubmissionChangeStateInput!) {
    submissionChangeState(input: $input) {
      submission {
        id
        slug
        state

        availableTransitions {
          toState
          lockedState
          mutableState

          canTransition {
            ... AuthorizationResultFragment
          }
        }

        currentStatus {
          toState
          lockedState
          mutableState
        }

        entity {
          __typename

          canUpdate {
            ... AuthorizationResultFragment
          }
        }

        transitions {
          nodes {
            id
            fromState
            toState
          }
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
  let_mutation_input!(:to_state) { "SUBMITTED" }

  let(:provisional_status) do
    Submissions::Status.new(submission, to_state: to_state.downcase)
  end

  let(:is_depositor) { false }

  let(:valid_mutation_shape) do
    gql.mutation(:submission_change_state) do |m|
      m.prop(:submission) do |s|
        s[:id] = submission_id
        s[:state] = to_state

        s.prop :current_status do |cs|
          cs[:to_state] = to_state
          cs[:mutable_state] = provisional_status.mutable_state
          cs[:locked_state] = provisional_status.locked_state
        end

        s.array :available_transitions do |ats|
          ats.item do |at|
            at[:to_state] = "DRAFT"
            at[:locked_state] = false
            at[:mutable_state] = true
            at.prop :can_transition do |ct|
              ct[:value] = true
            end
          end

          ats.item do |at|
            at[:to_state] = "UNDER_REVIEW"
            at[:locked_state] = true
            at[:mutable_state] = false
            at.prop :can_transition do |ct|
              ct[:value] = !is_depositor
            end
          end
        end
      end
    end
  end

  let(:empty_mutation_shape) do
    gql.empty_mutation :submission_change_state
  end

  shared_examples_for "a failed transition" do
    it "fails" do
      expect_request! do |req|
        req.effect! keep_the_same { submission.current_state(force_reload: true) }
        req.effect! keep_the_same(SubmissionTransition, :count)

        req.data! expected_shape
      end
    end
  end

  shared_examples_for "a successful mutation" do
    let(:expected_shape) { valid_mutation_shape }

    it "transitions the submission" do
      expect_request! do |req|
        req.effect! change { submission.current_state(force_reload: true) }.from("draft").to(to_state.downcase)

        req.data! expected_shape
      end
    end

    context "when trying to transition to the same state" do
      let(:to_state) { "DRAFT" }

      let(:expected_shape) do
        gql.mutation(:submission_change_state, no_global_errors: false) do |m|
          m[:submission] = be_blank

          m.global_errors do |ge|
            ge.error :unavailable_transition, message_args: { value: "draft" }
          end

          m.attribute_errors do |ae|
            ae.error :to_state, :must_be_new_state
          end
        end
      end

      include_examples "a failed transition"
    end

    context "when trying to transition to an invalid state" do
      before do
        submission.transition_to! :submitted
        submission.transition_to! :under_review
        submission.transition_to! :revision_requested
      end

      let(:to_state) { "DRAFT" }

      let(:expected_shape) do
        gql.mutation(:submission_change_state, no_global_errors: false) do |m|
          m[:submission] = be_blank

          m.global_errors do |ge|
            ge.error :unavailable_transition, message_args: { value: to_state.downcase }
          end
        end
      end

      include_examples "a failed transition"
    end

    context "when trying to publish outside of publish mutations" do
      let(:to_state) { "PUBLISHED" }

      before do
        submission.transition_to! :submitted
        submission.transition_to! :under_review
        submission.transition_to! :approved
      end

      include_examples "an unauthorized mutation"
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

    let_it_be(:depositor_role) { Role.fetch(:depositor) }

    context "as a depositor" do
      let(:is_depositor) { true }

      before do
        grant_access!(depositor_role, on: collection, to: current_user)
      end

      include_examples "an authorized mutation" do
        context "when trying to transition without permission" do
          before do
            submission.transition_to! :submitted
          end

          let(:to_state) { "UNDER_REVIEW" }

          include_examples "an unauthorized mutation"
        end
      end
    end
  end

  as_an_anonymous_user do
    include_examples "an unauthorized mutation"
  end
end

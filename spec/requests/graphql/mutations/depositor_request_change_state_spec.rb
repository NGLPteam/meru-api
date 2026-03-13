# frozen_string_literal: true

RSpec.describe Mutations::DepositorRequestChangeState, type: :request, graphql: :mutation do
  mutation_query! <<~GRAPHQL
  mutation DepositorRequestChangeState($input: DepositorRequestChangeStateInput!) {
    depositorRequestChangeState(input: $input) {
      depositorRequest {
        id
        slug
        state

        transitions {
          nodes {
            fromState
            toState
            user {
              id
            }
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

  let_it_be(:requestor, refind: true) do
    FactoryBot.create(:user)
  end

  let_it_be(:existing_depositor_request_attrs) do
    {
      submission_target:,
      user: requestor,
    }
  end

  let_it_be(:existing_depositor_request, refind: true) { FactoryBot.create(:depositor_request, **existing_depositor_request_attrs) }

  let_mutation_input!(:depositor_request_id) { existing_depositor_request.to_encoded_id }

  let_mutation_input!(:to_state) { "APPROVED" }

  let(:expected_from_state) { "PENDING" }

  let(:valid_mutation_shape) do
    gql.mutation(:depositor_request_change_state) do |m|
      m.prop(:depositor_request) do |dr|
        dr[:id] = be_an_encoded_id.of_an_existing_model
        dr[:slug] = be_an_encoded_slug
        dr[:state] = to_state

        dr.prop :transitions do |ts|
          ts.array :nodes do |ns|
            ns.item do |n|
              n[:from_state] = expected_from_state
              n[:to_state] = to_state
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
    gql.empty_mutation :depositor_request_change_state
  end

  shared_examples_for "a successful mutation" do
    let(:expected_shape) { valid_mutation_shape }

    it "approves the depositor request" do
      expect_request! do |req|
        req.effect! change { existing_depositor_request.current_state(force_reload: true) }.from("pending").to(to_state.downcase)
        req.effect! change(AccessGrant, :count).by(1)
        req.effect! change(DepositorAgreement, :count).by(1)
        req.effect! change(DepositorAgreementTransition, :count).by(2)
        req.effect! change { submission_target.reload.has_accepted_agreement?(requestor) }.from(false).to(true)

        req.data! expected_shape
      end
    end

    context "when rejecting a request" do
      let(:to_state) { "REJECTED" }

      it "rejects the depositor request" do
        expect_request! do |req|
          req.effect! change { existing_depositor_request.current_state(force_reload: true) }.from("pending").to(to_state.downcase)
          req.effect! keep_the_same(AccessGrant, :count)
          req.effect! keep_the_same(DepositorAgreement, :count)
          req.effect! keep_the_same(DepositorAgreementTransition, :count)
          req.effect! keep_the_same { submission_target.reload.has_accepted_agreement?(requestor) }

          req.data! expected_shape
        end

        expect(submission_target).not_to have_accepted_agreement(requestor)
      end
    end

    context "when unapproving a request" do
      before do
        existing_depositor_request.transition_to! :approved
      end

      let(:expected_from_state) { "APPROVED" }

      let(:to_state) { "PENDING" }

      it "revokes the access grant but maintains the agreement" do
        expect_request! do |req|
          req.effect! change { existing_depositor_request.current_state(force_reload: true) }.from("approved").to("pending")
          req.effect! change(AccessGrant, :count).by(-1)
          req.effect! keep_the_same(DepositorAgreement, :count)
          req.effect! keep_the_same(DepositorAgreementTransition, :count)
          req.effect! keep_the_same { submission_target.reload.has_accepted_agreement?(requestor) }

          req.data! expected_shape
        end

        expect(submission_target).to have_accepted_agreement(requestor)
      end
    end

    context "when the request is already in the target state" do
      before do
        existing_depositor_request.transition_to! to_state.downcase
      end

      let(:expected_shape) do
        gql.mutation(:depositor_request_change_state, no_errors: false) do |m|
          m[:depositor_request] = be_blank

          m.global_errors do |ge|
            ge.error :unavailable_transition, message_args: { value: "approved" }
          end

          m.attribute_errors do |ae|
            ae.error :to_state, :must_be_new_state
          end
        end
      end

      it "fails as expected" do
        expect_request! do |req|
          req.effect! keep_the_same { existing_depositor_request.current_state(force_reload: true) }
          req.effect! keep_the_same(AccessGrant, :count)

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

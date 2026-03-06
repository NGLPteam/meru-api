# frozen_string_literal: true

RSpec.describe Mutations::DepositorRequestCreate, type: :request, graphql: :mutation do
  mutation_query! <<~GRAPHQL
  mutation DepositorRequestCreate($input: DepositorRequestCreateInput!) {
    depositorRequestCreate(input: $input) {
      depositorRequest {
        id
        slug
        state
        message

        canTransition {
          ... AuthorizationResultFragment
        }

        submissionTarget {
          canRequestDepositAccess {
            ... AuthorizationResultFragment
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

  let_mutation_input!(:submission_target_id) { submission_target.to_encoded_id }

  let_mutation_input!(:message) { "I would like to be a depositor." }

  let(:can_transition) { false }
  let(:can_request_deposit_access) { false }

  let(:valid_mutation_shape) do
    gql.mutation(:depositor_request_create) do |m|
      m.prop(:depositor_request) do |dr|
        dr[:id] = be_an_encoded_id.of_an_existing_model
        dr[:slug] = be_an_encoded_slug
        dr[:state] = "PENDING"
        dr[:message] = message

        dr.auth_results(can_transition:)

        dr.prop :submission_target do |st|
          st.auth_results(can_request_deposit_access:)
        end
      end
    end
  end

  let(:empty_mutation_shape) do
    gql.empty_mutation :depositor_request_create
  end

  shared_examples_for "a successful mutation" do
    let(:expected_shape) { valid_mutation_shape }

    it "creates the depositor request" do
      expect_request! do |req|
        req.effect! change(DepositorRequest, :count).by(1)

        req.data! expected_shape
      end
    end

    context "when the user already has a pending request for the submission target" do
      let!(:existing_depositor_request) do
        FactoryBot.create(:depositor_request, submission_target:, user: current_user)
      end

      include_examples "an unauthorized mutation"
    end
  end

  shared_examples_for "an unauthorized mutation" do
    let(:expected_shape) { empty_mutation_shape }

    it "is not authorized" do
      expect_request! do |req|
        req.effect! keep_the_same(DepositorRequest, :count)

        req.unauthorized!

        req.data! expected_shape
      end
    end
  end

  shared_examples_for "an authorized mutation" do
    include_examples "a successful mutation"
  end

  as_an_admin_user do
    # Admins already have implicit deposit access. We prevent them.
    include_examples "an unauthorized mutation"
  end

  as_a_regular_user do
    include_examples "an authorized mutation"
  end

  as_an_anonymous_user do
    include_examples "an unauthorized mutation"
  end
end

# frozen_string_literal: true

RSpec.describe Mutations::DepositorAgreementResetAll, type: :request, graphql: :mutation do
  mutation_query! <<~GRAPHQL
  mutation DepositorAgreementResetAll($input: DepositorAgreementResetAllInput!) {
    depositorAgreementResetAll(input: $input) {
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

  let_it_be(:submitter, refind: true) do
    FactoryBot.create(:user, depositor_on: collection)
  end

  let_it_be(:depositor_agreement, refind: true) do
    FactoryBot.create(:depositor_agreement, :accepted, submission_target:, user: submitter)
  end

  let_mutation_input!(:submission_target_id) { submission_target.to_encoded_id }

  let(:valid_mutation_shape) do
    gql.mutation(:depositor_agreement_reset_all) do |m|
      m.prop(:submission_target) do |st|
        st[:id] = submission_target_id
      end
    end
  end

  let(:empty_mutation_shape) do
    gql.empty_mutation :depositor_agreement_reset_all
  end

  shared_examples_for "a successful mutation" do
    let(:expected_shape) { valid_mutation_shape }

    it "resets all the accepted agreements on the submission target" do
      expect_request! do |req|
        req.effect! change { depositor_agreement.current_state(force_reload: true) }.from("accepted").to("pending")

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
  end

  as_an_anonymous_user do
    include_examples "an unauthorized mutation"
  end
end

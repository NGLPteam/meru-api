# frozen_string_literal: true

RSpec.describe Mutations::DepositorAgreementReset, type: :request, graphql: :mutation do
  mutation_query! <<~GRAPHQL
  mutation DepositorAgreementReset($input: DepositorAgreementResetInput!) {
    depositorAgreementReset(input: $input) {
      depositorAgreement {
        id
        state
        lastAcceptedAt

        submissionTarget {
          id
        }

        user {
          id
        }

        canAccept {
          ... AuthorizationResultFragment
        }

        canReset {
          ... AuthorizationResultFragment
        }

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

  let_it_be(:submitter, refind: true) do
    FactoryBot.create(:user, depositor_on: collection)
  end

  let_mutation_input!(:submission_target_id) { submission_target.to_encoded_id }

  let_mutation_input!(:user_id) { submitter.to_encoded_id }

  let(:can_accept) { false }
  let(:can_reset) { false }

  let(:expected_from_state) { nil }

  let(:valid_mutation_shape) do
    gql.mutation(:depositor_agreement_reset) do |m|
      m.prop :depositor_agreement do |da|
        da[:id] = be_an_encoded_id.of_an_existing_model
        da[:state] = "PENDING"

        da.prop :submission_target do |st|
          st[:id] = submission_target_id
        end

        da.prop :user do |u|
          u[:id] = user_id
        end

        da.auth_results(can_accept:, can_reset:)

        da.prop :transitions do |ts|
          ts.array :nodes do |ns|
            ns.item do |n|
              n[:from_state] = expected_from_state
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
    gql.empty_mutation :depositor_agreement_reset
  end

  shared_examples_for "a successful mutation" do
    let(:expected_shape) { valid_mutation_shape }

    it "resets the depositor agreement idempotently" do
      expect_request! do |req|
        req.effect! change(DepositorAgreement, :count).by(1)
        req.effect! change(DepositorAgreementTransition.to_pending, :count).by(1)
        req.effect! keep_the_same(DepositorAgreementTransition.to_accepted, :count)

        req.data! expected_shape
      end
    end

    context "when the depositor agreement has been accepted" do
      let!(:depositor_agreement) { FactoryBot.create(:depositor_agreement, :accepted, submission_target:, user: submitter) }

      let(:expected_from_state) { "ACCEPTED" }

      it "resets the depositor agreement" do
        expect_request! do |req|
          req.effect! keep_the_same(DepositorAgreement, :count)
          req.effect! change(DepositorAgreementTransition.to_pending, :count).by(1)
          req.effect! keep_the_same(DepositorAgreementTransition.to_accepted, :count)
          req.effect! change { depositor_agreement.current_state(force_reload: true) }.from("accepted").to("pending")

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
    let(:can_reset) { true }

    include_examples "an authorized mutation"
  end

  as_a_regular_user do
    include_examples "an unauthorized mutation"

    context "even when the user has depositor access to the collection" do
      let(:current_user) { submitter }

      include_examples "an unauthorized mutation"
    end
  end

  as_an_anonymous_user do
    include_examples "an unauthorized mutation"
  end
end

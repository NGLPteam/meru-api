# frozen_string_literal: true

RSpec.describe Mutations::SubmissionTargetClose, type: :request, graphql: :mutation do
  mutation_query! <<~GRAPHQL
  mutation SubmissionTargetClose($input: SubmissionTargetCloseInput!) {
    submissionTargetClose(input: $input) {
      submissionTarget {
        id
        state
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

  let(:valid_mutation_shape) do
    gql.mutation(:submission_target_close) do |m|
      m.prop(:submission_target) do |st|
        st[:id] = submission_target_id
        st[:state] = "CLOSED"
      end
    end
  end

  let(:empty_mutation_shape) do
    gql.empty_mutation :submission_target_close
  end

  shared_examples_for "a successful mutation" do
    let(:expected_shape) { valid_mutation_shape }

    it "closes the submission target" do
      expect_request! do |req|
        req.effect! change { submission_target.current_state(force_reload: true) }.from("open").to("closed")

        req.data! expected_shape
      end
    end

    context "when it is already closed" do
      before do
        submission_target.transition_to! :closed
      end

      let(:expected_shape) do
        gql.mutation(:submission_target_close, no_errors: false) do |m|
          m[:submission_target] = be_blank

          m.global_errors do |ge|
            ge.error :unavailable_transition, message_args: { value: "closed" }
          end
        end
      end

      it "is fails as expected" do
        expect_request! do |req|
          req.effect! keep_the_same { submission_target.current_state(force_reload: true) }

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

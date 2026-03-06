# frozen_string_literal: true

RSpec.describe Mutations::SubmissionCreate, type: :request, graphql: :mutation, grants_access: true do
  mutation_query! <<~GRAPHQL
  mutation SubmissionCreate($input: SubmissionCreateInput!) {
    submissionCreate(input: $input) {
      submission {
        id
        slug

        submissionTarget {
          id

          canDeposit {
            ... AuthorizationResultFragment
          }
        }

        entity {
          __typename

          id

          title

          canUpdate {
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
  let_mutation_input!(:schema_version_id) { item_schema_version.to_encoded_id }
  let_mutation_input!(:parent_entity_id) { collection.to_encoded_id }
  let_mutation_input!(:title) { "Test Submission" }

  let(:valid_mutation_shape) do
    gql.mutation(:submission_create) do |m|
      m.prop(:submission) do |s|
        s[:id] = be_an_encoded_id.of_an_existing_model
        s[:slug] = be_an_encoded_slug

        s.prop :submission_target do |st|
          st[:id] = submission_target_id

          st.prop :can_deposit do |cd|
            cd[:value] = true
          end
        end

        s.prop :entity do |e|
          e.typename("Item")
          e[:id] = be_an_encoded_id.of_an_existing_model

          e.prop :can_update do |cu|
            cu[:value] = true
          end
        end
      end
    end
  end

  let(:empty_mutation_shape) do
    gql.empty_mutation :submission_create
  end

  shared_examples_for "a successful mutation" do
    let(:expected_shape) { valid_mutation_shape }

    it "creates the submission" do
      expect_request! do |req|
        req.effect! change(Submission, :count).by(1)
        req.effect! change(Item, :count).by(1)

        req.data! expected_shape
      end
    end
  end

  shared_examples_for "an unauthorized mutation" do
    let(:expected_shape) { empty_mutation_shape }

    it "is not authorized" do
      expect_request! do |req|
        req.effect! execute_safely
        req.effect! keep_the_same(Submission, :count)

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
      before do
        grant_access!(depositor_role, on: collection, to: current_user)
      end

      include_examples "an authorized mutation"
    end
  end

  as_an_anonymous_user do
    include_examples "an unauthorized mutation"
  end
end

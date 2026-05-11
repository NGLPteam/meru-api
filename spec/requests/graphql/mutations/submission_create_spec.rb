# frozen_string_literal: true

RSpec.describe Mutations::SubmissionCreate, type: :request, graphql: :mutation, grants_access: true do
  mutation_query! <<~GRAPHQL
  mutation SubmissionCreate($input: SubmissionCreateInput!) {
    submissionCreate(input: $input) {
      submission {
        id
        slug

        agreementAcceptedAt

        submissionTarget {
          id

          canDeposit {
            ... AuthorizationResultFragment
          }
        }

        entity {
          ... EntityFragment
        }
      }

      ... ErrorFragment
    }
  }

  fragment EntityFragment on Entity {
    __typename
    id
    title

    canUpdate {
      ... AuthorizationResultFragment
    }

    canDestroy {
      ... AuthorizationResultFragment
    }

    ... on Item {
      ... ItemFragment
    }
  }

  fragment ItemFragment on Item {
    id
    title

    contributions {
      nodes {
        ... ContributionFragment
      }
    }
  }

  fragment PersonFragment on PersonContributor {
    givenName
    familyName
  }

  fragment ContributorFragment on Contributor {
    __typename

    ... on PersonContributor {
      ... PersonFragment

      canDestroy {
        ... AuthorizationResultFragment
      }

      canUpdate {
        ... AuthorizationResultFragment
      }
    }

    userLink {
      linkage

      user {
        id
      }
    }
  }

  fragment ContributionFragment on ItemContribution {
    contributionRole {
      label
    }

    contributor {
      ... ContributorFragment
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
  let_mutation_input!(:agreement_accepted) { true }

  let(:can_update_contributor) { true }
  let(:can_destroy_contributor) { false }

  let(:can_update_entity) { true }
  let(:can_destroy_entity) { false }

  let(:valid_mutation_shape) do
    gql.mutation(:submission_create) do |m|
      m.prop(:submission) do |s|
        s[:id] = be_an_encoded_id.of_an_existing_model
        s[:slug] = be_an_encoded_slug

        s[:agreement_accepted_at] = be_present

        s.prop :submission_target do |st|
          st[:id] = submission_target_id

          st.auth_results(can_deposit: true)
        end

        s.prop :entity do |e|
          e.typename("Item")
          e[:id] = be_an_encoded_id.of_an_existing_model

          e.auth_results(can_update: can_update_entity, can_destroy: can_destroy_entity)

          e.prop :contributions do |cont|
            cont.array :nodes do |n|
              n.item do |node|
                node.prop :contribution_role do |cr|
                  cr[:label] = "Author"
                end

                node.prop :contributor do |c|
                  c.typename("PersonContributor")

                  c.auth_results(can_update: can_update_contributor, can_destroy: can_destroy_contributor)

                  c[:given_name] = current_user.given_name
                  c[:family_name] = current_user.family_name

                  c.prop :user_link do |ul|
                    ul[:linkage] = "PRIMARY"

                    ul.prop :user do |u|
                      u[:id] = current_user.to_encoded_id
                    end
                  end
                end
              end
            end
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
        req.effect! change(Contributor, :count).by(1)
        req.effect! change(ItemContribution, :count).by(1)
        req.effect! change { current_user.reload.primary_contributor }.from(nil).to(a_kind_of(Contributor))

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

    context "when the agreement is not accepted" do
      let_mutation_input!(:agreement_accepted) { false }

      let(:expected_shape) do
        gql.mutation(:submission_create) do |m|
          m[:submission] = nil
          m.global_errors do |ge|
            ge.error :depositor_agreement_required
          end
        end
      end

      it "fails validation" do
        expect_request! do |req|
          req.effect! keep_the_same(Submission, :count)

          req.data! expected_shape
        end
      end
    end
  end

  as_an_admin_user do
    let(:can_destroy_contributor) { true }

    include_examples "an authorized mutation"
  end

  as_a_regular_user do
    include_examples "an unauthorized mutation"

    let_it_be(:depositor_role) { Role.fetch(:depositor) }

    context "as a depositor" do
      before do
        grant_access!(depositor_role, on: collection, to: current_user)
      end

      context "without an active depositor agreement" do
        include_examples "an unauthorized mutation"
      end

      context "with an active depositor agreement" do
        before do
          submission_target.accept_agreement_for!(current_user)
        end

        include_examples "an authorized mutation"
      end
    end
  end

  as_an_anonymous_user do
    include_examples "an unauthorized mutation"
  end
end

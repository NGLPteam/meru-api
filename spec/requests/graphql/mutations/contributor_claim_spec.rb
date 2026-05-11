# frozen_string_literal: true

RSpec.describe Mutations::ContributorClaim, type: :request, graphql: :mutation, grants_access: true do
  mutation_query! <<~GRAPHQL
  mutation ContributorClaim($input: ContributorClaimInput!) {
    contributorClaim(input: $input) {
      contributor {
        ... ContributorFragment
      }

      user {
        ... UserFragment
      }

      contributorUserLink {
        id
        slug
        linkage

        contributor {
          ... ContributorFragment
        }

        user {
          ... UserFragment
        }
      }

      ... ErrorFragment
    }
  }

  fragment ContributorFragment on Contributor {
    ... on Node {
      id
    }

    ... on Sluggable {
      slug
    }

    ... on ContributorBase {
      kind
      claimed

      canClaim {
        ... AuthorizationResultFragment
      }

      canLinkUser {
        ... AuthorizationResultFragment
      }

      canMergeSource {
        ... AuthorizationResultFragment
      }

      canMergeTarget {
        ... AuthorizationResultFragment
      }
    }
  }

  fragment UserFragment on User {
    id
    slug

    canClaimContributor {
      ... AuthorizationResultFragment
    }

    primaryContributor {
      ... ContributorFragment
    }
  }
  GRAPHQL

  let_it_be(:community, refind: true) { FactoryBot.create(:community) }
  let_it_be(:collection, refind: true) { FactoryBot.create(:collection, community:) }

  let_it_be(:depositor_role) { Role.fetch(:depositor) }
  let_it_be(:reviewer_role) { Role.fetch(:reviewer) }

  let_it_be(:other_user, refind: true) { FactoryBot.create :user }

  let_it_be(:unclaimed_contributor, refind: true) { FactoryBot.create :contributor, :person }

  let_it_be(:claimed_contributor, refind: true) do
    FactoryBot.create(:contributor, :person).tap do |contributor|
      contributor.link_user!(other_user, linkage: :primary)
    end
  end

  let_it_be(:other_contributor, refind: true) { FactoryBot.create :contributor, :person }

  let(:can_claim) { false }
  let(:can_link_user) { false }
  let(:can_merge_source) { false }
  let(:can_merge_target) { false }

  let(:can_claim_contributor) { false }

  let!(:contributor) { unclaimed_contributor }
  let!(:user) { current_user }
  let!(:user_id) { user.to_encoded_id }

  let_mutation_input!(:contributor_id) { contributor.to_encoded_id }

  let(:valid_mutation_shape) do
    gql.mutation(:contributor_claim) do |m|
      m.prop(:contributor) do |c|
        c[:id] = contributor_id
        c[:slug] = contributor.system_slug

        c.auth_results(can_claim:, can_link_user:, can_merge_source:, can_merge_target:)
      end

      m.prop(:user) do |u|
        u[:id] = user_id
        u[:slug] = user.system_slug

        u.auth_results(can_claim_contributor:)
      end

      m.prop(:contributor_user_link) do |cul|
        cul[:id] = be_an_encoded_id.of_an_existing_model
        cul[:slug] = be_an_encoded_slug

        cul[:linkage] = "PRIMARY"

        cul.prop(:contributor) do |c|
          c[:id] = contributor_id
          c[:slug] = contributor.system_slug

          c.auth_results(can_claim:, can_link_user:, can_merge_source:, can_merge_target:)
        end

        cul.prop(:user) do |u|
          u[:id] = user_id
          u[:slug] = user.system_slug

          u.auth_results(can_claim_contributor:)
        end
      end
    end
  end

  let(:empty_mutation_shape) do
    gql.empty_mutation :contributor_claim
  end

  shared_examples_for "a successful mutation" do
    let(:expected_shape) { valid_mutation_shape }

    it "claims the contributor" do
      expect_request! do |req|
        req.effect! change(ContributorUserLink, :count).by(1)
        req.effect! change { contributor.reload.claimed? }.from(false).to(true)

        req.data! expected_shape
      end
    end

    context "when the contributor is already claimed" do
      let!(:contributor) { claimed_contributor }

      include_examples "an unauthorized mutation"
    end

    context "when the user is already linked to a contributor" do
      before do
        current_user.link_contributor!(other_contributor, linkage: :primary)
      end

      include_examples "an unauthorized mutation"
    end

    context "when claiming is disabled" do
      before do
        GlobalConfiguration.current.tap do |config|
          config.contributors.claimable = false
          config.save!
        end
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
    let(:can_link_user) { true }
    let(:can_merge_source) { true }
    let(:can_merge_target) { true }

    include_examples "an authorized mutation"
  end

  as_a_regular_user do
    include_examples "an unauthorized mutation"

    context "as a depositor" do
      before do
        grant_access!(depositor_role, on: collection, to: current_user)
      end

      include_examples "an authorized mutation"
    end

    context "as a reviewer" do
      before do
        grant_access!(reviewer_role, on: collection, to: current_user)
      end

      include_examples "an authorized mutation"
    end
  end

  as_an_anonymous_user do
    include_examples "an unauthorized mutation"
  end
end

# frozen_string_literal: true

RSpec.describe Mutations::ContributorUserLinkUpsert, type: :request, graphql: :mutation do
  mutation_query! <<~GRAPHQL
  mutation ContributorUserLinkUpsert($input: ContributorUserLinkUpsertInput!) {
    contributorUserLinkUpsert(input: $input) {
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
    }
  }

  fragment UserFragment on User {
    id
    slug

    primaryContributor {
      ... ContributorFragment
    }
  }
  GRAPHQL

  let_it_be(:other_contributor, refind: true) do
    FactoryBot.create(:contributor, :person)
  end

  let_it_be(:other_user, refind: true) { FactoryBot.create(:user) }

  let_it_be(:contributor, refind: true) { FactoryBot.create(:contributor, :person) }

  let_it_be(:user, refind: true) { FactoryBot.create(:user) }

  let_mutation_input!(:contributor_id) { contributor.to_encoded_id }
  let_mutation_input!(:user_id) { user.to_encoded_id }
  let_mutation_input!(:linkage) { "PRIMARY" }

  let(:valid_mutation_shape) do
    gql.mutation(:contributor_user_link_upsert) do |m|
      m.prop(:contributor) do |c|
        c[:id] = contributor_id
        c[:slug] = contributor.system_slug
      end

      m.prop(:user) do |u|
        u[:id] = user_id
        u[:slug] = user.system_slug
      end

      m.prop(:contributor_user_link) do |cul|
        cul[:id] = be_an_encoded_id.of_an_existing_model
        cul[:slug] = be_an_encoded_slug

        cul[:linkage] = linkage

        cul.prop(:contributor) do |c|
          c[:id] = contributor_id
          c[:slug] = contributor.system_slug
        end

        cul.prop(:user) do |u|
          u[:id] = user_id
          u[:slug] = user.system_slug
        end
      end
    end
  end

  let(:empty_mutation_shape) do
    gql.empty_mutation :contributor_user_link_upsert
  end

  shared_examples_for "a successful mutation" do
    let(:expected_shape) { valid_mutation_shape }

    it "links the contributor and the user" do
      expect_request! do |req|
        req.effect! change(ContributorUserLink, :count).by(1)

        req.effect! change { user.reload_primary_contributor }.from(nil).to(contributor)

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

    context "when the contributor / user link pair already exists" do
      let!(:existing_link) do
        FactoryBot.create(:contributor_user_link, contributor:, user:, linkage: "auxiliary")
      end

      it "updates the existing link" do
        expect_request! do |req|
          req.effect! change { existing_link.reload.linkage }.from("auxiliary").to("primary")
        end
      end
    end

    context "when a primary link already exists for the user" do
      let!(:existing_link) do
        FactoryBot.create(:contributor_user_link, :primary, user:, contributor: other_contributor)
      end

      it "overrides the existing primary link" do
        expect_request! do |req|
          req.effect! change { existing_link.reload.linkage }.from("primary").to("auxiliary")
        end
      end
    end

    context "when a link already exists for the contributor but with a different user" do
      let!(:existing_link) do
        FactoryBot.create(:contributor_user_link, contributor:, user: other_user, linkage: "primary")
      end

      it "updates the existing link to point to the new user" do
        expect_request! do |req|
          req.effect! change { other_user.reload_primary_contributor }.from(contributor).to(nil)
          req.effect! change { existing_link.reload.user }.from(existing_link.user).to(user)
        end
      end
    end
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

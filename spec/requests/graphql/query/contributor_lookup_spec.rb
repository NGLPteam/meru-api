# frozen_string_literal: true

RSpec.describe "Query.contributorLookup", type: :request do
  let!(:query) do
    <<~GRAPHQL
    query lookupContributor($by: ContributorLookupField!, $value: String!) {
      contributor: contributorLookup(by: $by, value: $value) {
        ... AnyContributorDetailsFragment
      }
    }

    fragment AnyContributorDetailsFragment on Contributor {
      ... on OrganizationContributor {
        slug

        ... ContributorDetailsFragment
      }

      ... on PersonContributor {
        slug

        ... ContributorDetailsFragment
      }
    }

    fragment ContributorDetailsFragment on Contributor {
      __typename

      kind
    }
    GRAPHQL
  end

  let(:known_email) { Faker::Internet.email }
  let(:known_name) { Faker::Company.name }
  let(:known_orcid) { Testing::ORCID.random }

  let!(:contributor) { FactoryBot.create :contributor, :organization, email: known_email, orcid: known_orcid, legal_name: known_name }

  let(:by) { "NAME" }
  let(:value) { "" }

  let(:graphql_variables) do
    { by:, value: }
  end

  shared_examples_for "a found contributor" do
    let(:expected_shape) do
      gql.object do |q|
        q.prop :contributor do |c|
          c[:kind] = contributor.kind
          c[:slug] = contributor.system_slug
        end
      end
    end

    it "finds the right contributor" do
      expect_the_default_request.to execute_safely

      expect_graphql_data expected_shape
    end
  end

  shared_examples_for "a missed contributor" do
    let(:expected_shape) do
      gql.object do |q|
        q[:contributor] = nil
      end
    end

    it "finds no contributor" do
      expect_the_default_request.to execute_safely

      expect_graphql_data expected_shape
    end
  end

  shared_examples_for "a lookup" do |value_name|
    context "with a known value" do
      let(:value) { __send__ value_name }

      include_examples "a found contributor"
    end

    context "with an unknown value" do
      let(:value) { "guaranteed to not be found" }

      include_examples "a missed contributor"
    end
  end

  context "as an admin" do
    let(:token) { token_helper.build_token has_global_admin: true }

    context "when looking up by EMAIL" do
      let(:by) { "EMAIL" }

      include_examples "a lookup", :known_email
    end

    context "when looking up by NAME" do
      let(:by) { "NAME" }

      include_examples "a lookup", :known_name
    end

    context "when looking up by ORCID" do
      let(:by) { "ORCID" }

      include_examples "a lookup", :known_orcid
    end
  end
end

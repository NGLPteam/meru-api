# frozen_string_literal: true

RSpec.describe "GraphQL Query", type: :request do
  as_an_admin_user do
    describe "using the relay node resolver" do
      let_it_be(:collection) { FactoryBot.create :collection }

      let(:expected_shape) do
        gql.query do |q|
          q.prop :node do |n|
            n[:title] = collection.title
          end
        end
      end

      let(:query) do
        <<~GRAPHQL
        query($id: ID!) {
          node(id: $id) {
            ... on Collection {
              title
            }
          }
        }
        GRAPHQL
      end

      let(:graphql_variables) do
        { id: collection.to_encoded_id }
      end

      it "works as expected" do
        expect_request! do |req|
          req.data! expected_shape
        end
      end
    end

    describe "fetching a list of communities" do
      let!(:communities) { FactoryBot.create_list :community, 5 }

      let(:query) do
        <<~GRAPHQL
        query getCommunities {
          communities {
            nodes {
              id
            }
          }
        }
        GRAPHQL
      end

      let(:expected_shape) do
        gql.query do |q|
          q.prop :communities do |c|
            c[:nodes] = have_length(5)
          end
        end
      end

      it "has the expected count" do
        expect_request! do |req|
          req.data! expected_shape
        end
      end
    end

    describe "fetching a list of roles" do
      let_it_be(:roles, refind: true) { FactoryBot.create_list :role, 4 }

      let(:query) do
        <<~GRAPHQL
        query getRoles {
          roles {
            nodes {
              id
              allowedActions
            }
          }
        }
        GRAPHQL
      end

      let(:expected_shape) do
        gql.query do |q|
          q.prop :roles do |c|
            c[:nodes] = have_length(Role.count)
          end
        end
      end

      it "fetches all known roles in the system" do
        expect_request! do |req|
          req.data! expected_shape
        end
      end
    end

    describe "fetching contributors" do
      let!(:people) { FactoryBot.create_list :contributor, 2, :person }
      let!(:organizations) { FactoryBot.create_list :contributor, 2, :organization }

      let(:filter_kind) { "ALL" }

      let!(:graphql_variables) do
        {
          kind: filter_kind
        }
      end

      let!(:query) do
        <<~GRAPHQL
        query getContributors($kind: ContributorFilterKind) {
          contributors(kind: $kind) {
            nodes {
              __typename

              ... on OrganizationContributor {
                legalName
              }

              ... on PersonContributor {
                givenName
                familyName
              }
            }
          }
        }
        GRAPHQL
      end

      let(:graphql_query_options) do
        {
          token:,
          variables: graphql_variables
        }
      end

      it "can fetch all contributors" do
        make_graphql_request! query, **graphql_query_options

        expect(graphql_response(:data, :contributors, :nodes)).to have(4).items
      end

      context "when filtering only organizations" do
        let(:filter_kind) { "ORGANIZATION" }

        it "fetches only people" do
          make_graphql_request! query, **graphql_query_options

          expect(graphql_response(:data, :contributors, :nodes)).to have(2).items.and all(include_json(__typename: "OrganizationContributor"))
        end
      end

      context "when filtering only people" do
        let(:filter_kind) { "PERSON" }

        it "fetches only people" do
          make_graphql_request! query, **graphql_query_options

          expect(graphql_response(:data, :contributors, :nodes)).to have(2).items.and all(include_json(__typename: "PersonContributor"))
        end
      end
    end
  end
end

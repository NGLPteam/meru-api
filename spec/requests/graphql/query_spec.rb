# frozen_string_literal: true

RSpec.describe "GraphQL Query", type: :request do
  as_an_admin_user do
    describe "using the relay node resolver" do
      let_it_be(:collection) { fixture(:collection) }

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
  end
end

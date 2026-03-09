# frozen_string_literal: true

RSpec.describe "Query.item", type: :request do
  let!(:query) do
    <<~GRAPHQL
    query getItem($slug: Slug!) {
      item(slug: $slug) {
        title

        applicableRoles {
          id
          name
        }

        allowedActions

        contributors {
          nodes {
            ... on OrganizationContributor {
              legalName
            }

            ... on PersonContributor {
              givenName
              familyName
            }
          }

          pageInfo {
            totalCount
          }
        }

        items {
          nodes { id }

          pageInfo {
            totalCount
          }
        }

        links {
          ... EntityLinksListDataFragment
        }
      }
    }

    fragment EntityLinksListDataFragment on EntityLinkConnection {
      nodes {
        id
        slug
        operator
        target {
          __typename
          ... on Item {
            slug
            title
            schemaDefinition {
              name
              kind
              id
            }
          }
          ... on Collection {
            slug
            title
            schemaDefinition {
              name
              kind
              id
            }
          }
          ... on Node {
            __isNode: __typename
            id
          }
        }
      }
    }
    GRAPHQL
  end

  let(:slug) { random_slug }

  let(:graphql_variables) { { slug:, } }

  let_it_be(:full_privilege_actions) do
    [
      "items.assets.create",
      "items.assets.delete",
      "items.assets.read",
      "items.assets.update",
      "items.create",
      "items.delete",
      "items.deposit",
      "items.manage_access",
      "items.read",
      "items.review",
      "items.update",
      "self.assets.create",
      "self.assets.delete",
      "self.assets.read",
      "self.assets.update",
      "self.create",
      "self.delete",
      "self.deposit",
      "self.manage_access",
      "self.read",
      "self.review",
      "self.update"
    ]
  end

  let_it_be(:item) { FactoryBot.create :item }

  let_it_be(:subitems) { FactoryBot.create_list :item, 2, parent: item }

  let_it_be(:contributors) do
    %i[person organization].map do |trait|
      FactoryBot.create :contributor, trait
    end
  end

  let_it_be(:item_contributions) do
    contributors.map do |contrib|
      FactoryBot.create :item_contribution, contributor: contrib, item:
    end
  end

  let(:expected_allowed_actions) { be_blank }
  let(:expected_contributors_count) { raise 'must be set' }

  shared_examples_for "a found item" do
    context "with a valid slug" do
      let(:slug) { item.system_slug }

      let(:expected_shape) do
        gql.query do |q|
          q.prop :item do |i|
            i[:title] = item.title

            i[:allowed_actions] = expected_allowed_actions

            i.prop :contributors do |c|
              c.prop :page_info do |pi|
                pi[:total_count] = expected_contributors_count
              end
            end

            i.prop :items do |is|
              is.prop :page_info do |pi|
                pi[:total_count] = subitems.size
              end
            end
          end
        end
      end

      it "has the expected shape" do
        expect_request! do |req|
          req.effect! change(Ahoy::Event, :count).by(1)

          req.data! expected_shape
        end
      end
    end

    context "with an invalid slug" do
      let(:slug) { random_slug }

      let(:expected_shape) do
        gql.query do |q|
          q[:item] = be_nil
        end
      end

      it "returns nil" do
        expect_request! do |req|
          req.data! expected_shape
        end
      end
    end
  end

  as_an_admin_user do
    let(:expected_allowed_actions) do
      match_array(full_privilege_actions)
    end

    let(:expected_contributors_count) { item_contributions.size }

    include_examples "a found item"
  end

  as_an_anonymous_user do
    let(:expected_contributors_count) { 0 }

    include_examples "a found item"
  end

  it_behaves_like "a graphql type with firstItem" do
    subject { item }
  end

  it_behaves_like "a graphql entity with layouts" do
    let(:entity) { item }
  end
end

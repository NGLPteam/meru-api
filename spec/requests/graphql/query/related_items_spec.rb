# frozen_string_literal: true

RSpec.describe "Query.item.relatedItems", type: :request, disable_ordering_refresh: true do
  let!(:query) do
    <<~GRAPHQL
    query getRelatedItems($slug: Slug!) {
      item(slug: $slug) {
        relatedItems {
          edges {
            node {
              id
            }
          }

          pageInfo { totalCount }
        }
      }
    }
    GRAPHQL
  end

  let(:token) { token_helper.build_token }

  let!(:graphql_variables) { { slug: source_item.system_slug } }

  let_it_be(:test_schema) { FactoryBot.create :schema_version, :item }
  let_it_be(:other_schema) { FactoryBot.create :schema_version, :item }

  let_it_be(:source_item) { FactoryBot.create :item, schema_version: test_schema }
  let_it_be(:target_item) { FactoryBot.create :item, schema_version: test_schema }
  let_it_be(:other_item) { FactoryBot.create :item, schema_version: other_schema }

  let_it_be(:target_link) { FactoryBot.create :entity_link, source: source_item, target: target_item }
  let_it_be(:other_link) { FactoryBot.create :entity_link, source: source_item, target: other_item }

  let!(:expected_shape) do
    gql.query do |q|
      q.prop :item do |i|
        i.prop :related_items do |ri|
          ri.array :edges do |es|
            es.item do |edge|
              edge.prop :node do |n|
                n[:id] = target_item.to_encoded_id
              end
            end
          end

          ri.prop :page_info do |pi|
            pi[:total_count] = 1
          end
        end
      end
    end
  end

  it "returns the right results" do
    expect_request! do |req|
      req.data! expected_shape
    end
  end
end

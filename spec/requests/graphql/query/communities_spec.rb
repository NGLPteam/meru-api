# frozen_string_literal: true

RSpec.describe "Query.communities", type: :request do
  let_it_be(:community_k0) do
    Timecop.freeze(1.hour.ago) do
      FactoryBot.create :community, title: "KK", position: 1
    end
  end

  let_it_be(:community_z1) do
    Timecop.freeze(1.day.ago) do
      FactoryBot.create :community, title: "ZZ", position: 2
    end
  end

  let_it_be(:community_m2) do
    Timecop.freeze(2.days.ago) do
      FactoryBot.create :community, title: "MM", position: 3
    end
  end

  let_it_be(:community_a3) do
    Timecop.freeze(3.days.ago) do
      FactoryBot.create :community, title: "AA", position: 4
    end
  end

  let_it_be(:community_n4) do
    Timecop.freeze(4.days.ago) do
      FactoryBot.create :community, title: "NN", position: 5
    end
  end

  let_it_be(:keyed_models) do
    %i[a3 k0 m2 n4 z1].index_with do |k|
      to_rep public_send :"community_#{k}"
    end
  end

  let!(:order) { "RECENT" }

  let!(:graphql_variables) do
    { order: }
  end

  let!(:query) do
    <<~GRAPHQL
    query getOrderedCommunities($order: EntityOrder!) {
      communities(order: $order) {
        edges {
          node {
            id
            position
            title
          }
        }

        pageInfo {
          totalCount
        }
      }
    }
    GRAPHQL
  end

  def to_rep(model)
    model.slice(:position, :title).merge(id: model.to_encoded_id)
  end

  context "when ordering" do
    let(:token) { token_helper.build_token has_global_admin: true }

    shared_examples_for "an ordered list of communities" do |order_value, *keys|
      let(:order) { order_value }

      let!(:expected_edges) do
        keys.map do |k|
          { node: keyed_models.fetch(k) }
        end
      end

      let!(:expected_shape) do
        gql.query do |q|
          q.prop :communities do |c|
            c[:edges] = expected_edges

            c.prop :page_info do |pi|
              pi[:total_count] = expected_edges.size
            end
          end
        end
      end

      it "returns communities in the expected order" do
        expect_request! do |req|
          req.data! expected_shape
        end
      end
    end

    {
      "RECENT" => %i[k0 z1 m2 a3 n4],
      "OLDEST" => %i[n4 a3 m2 z1 k0],
      "POSITION_ASCENDING" => %i[k0 z1 m2 a3 n4],
      "POSITION_DESCENDING" => %i[n4 a3 m2 z1 k0],
      "PUBLISHED_ASCENDING" => %i[n4 a3 m2 z1 k0],
      "PUBLISHED_DESCENDING" => %i[k0 z1 m2 a3 n4],
      "TITLE_ASCENDING" => %i[a3 k0 m2 n4 z1],
      "TITLE_DESCENDING" => %i[z1 n4 m2 k0 a3],
      "SCHEMA_NAME_ASCENDING" => %i[a3 k0 m2 n4 z1],
      "SCHEMA_NAME_DESCENDING" => %i[a3 k0 m2 n4 z1],
    }.each do |order, keys|
      context "when ordered by #{order}" do
        include_examples "an ordered list of communities", order, *keys
      end
    end
  end
end

# frozen_string_literal: true

RSpec.describe "Query.collections", type: :request do
  def community = fixture(:community)

  context "when ordering" do
    let_it_be(:collection_a3_202105, refind: true) do
      Timecop.freeze(3.days.ago) do
        FactoryBot.create :collection, community:, title: "AA", published: variable_date("2021-05"), schema: "nglp:journal_issue"
      end
    end

    let_it_be(:collection_m2_202103, refind: true) do
      Timecop.freeze(2.days.ago) do
        FactoryBot.create :collection, community:, title: "MM", published: variable_date("2021-03")
      end
    end

    let_it_be(:collection_n4_2021, refind: true) do
      Timecop.freeze(4.days.ago) do
        FactoryBot.create :collection, community:, title: "NN", published: variable_date(2021), schema: "nglp:journal_volume"
      end
    end

    let_it_be(:collection_z1_202104, refind: true) do
      Timecop.freeze(1.day.ago) do
        FactoryBot.create :collection, community:, title: "ZZ", published: variable_date("2021-04")
      end
    end

    let_it_be(:collection_k0, refind: true) do
      Timecop.freeze(1.hour.ago) do
        FactoryBot.create :collection, community:, title: "KK", published: nil, schema: "nglp:journal_volume"
      end
    end

    let!(:keyed_models) do
      {
        a3_202105: to_rep(collection_a3_202105),
        k0: to_rep(collection_k0),
        m2_202103: to_rep(collection_m2_202103),
        n4_2021: to_rep(collection_n4_2021),
        z1_202104: to_rep(collection_z1_202104),
      }
    end

    def to_rep(model)
      model.slice(:title).merge(id: model.to_encoded_id)
    end

    let!(:order) { "RECENT" }

    let!(:slug) { community.system_slug }

    let!(:graphql_variables) { { slug:, order: } }

    let!(:query) do
      <<~GRAPHQL
      query getOrderedCommunityCollections($order: EntityOrder!, $slug: Slug!) {
        community(slug: $slug) {
          collections(order: $order) {
            edges {
              node {
                id
                title
              }
            }
            pageInfo { totalCount }
          }
        }
      }
      GRAPHQL
    end

    around do |example|
      Collection.lock_to!(collection_a3_202105, collection_m2_202103, collection_n4_2021, collection_z1_202104, collection_k0) do
        example.run
      end
    end

    shared_examples_for "an ordered list of collections" do |order_value, *keys|
      let!(:order) { order_value }

      let!(:expected_shape) do
        {
          community: {
            collections: {
              edges: keys.map { |k| { node: keyed_models.fetch(k) } },
              page_info: { total_count: keyed_models.size },
            },
          },
        }
      end

      it "returns collections in the expected order" do
        expect_request! do |req|
          req.data! expected_shape
        end
      end
    end

    shared_examples_for "all ordering" do
      {
        "RECENT" => %i[k0 z1_202104 m2_202103 a3_202105 n4_2021],
        "OLDEST" => %i[n4_2021 a3_202105 m2_202103 z1_202104 k0],
        "PUBLISHED_ASCENDING" => %i[n4_2021 m2_202103 z1_202104 a3_202105 k0],
        "PUBLISHED_DESCENDING" => %i[a3_202105 z1_202104 m2_202103 n4_2021 k0],
        "TITLE_ASCENDING" => %i[a3_202105 k0 m2_202103 n4_2021 z1_202104],
        "TITLE_DESCENDING" => %i[z1_202104 n4_2021 m2_202103 k0 a3_202105],
        "SCHEMA_NAME_ASCENDING" => %i[m2_202103 z1_202104 a3_202105 k0 n4_2021],
        "SCHEMA_NAME_DESCENDING" => %i[k0 n4_2021 a3_202105 m2_202103 z1_202104]
      }.each do |order, keys|
        context "when ordered by #{order}" do
          include_examples "an ordered list of collections", order, *keys
        end
      end
    end

    as_an_admin_user do
      include_examples "all ordering"
    end
  end
end

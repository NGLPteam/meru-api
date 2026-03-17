# frozen_string_literal: true

RSpec.describe "Query.contributors", type: :request, disable_ordering_refresh: true do
  def create_person_contributor_at(time, item_count:, **attributes)
    Timecop.freeze time do
      FactoryBot.create(:contributor, :person, **attributes).tap do |contributor|
        FactoryBot.create_list(:item, item_count, collection:).map do |item|
          FactoryBot.create :item_contribution, contributor:, item:
        end
      end
    end
  end

  def shape_for(*keys)
    keys.flatten!

    gql.query do |q|
      q.prop :contributors do |u|
        u.array :edges do |e|
          keys.each do |k|
            e.item do |n|
              n[:node] = keyed_models.fetch k
            end
          end
        end

        u.prop :page_info do |pi|
          pi[:total_count] = keys.size
          pi[:total_unfiltered_count] = keyed_models.size
        end
      end
    end
  end

  def to_rep(model)
    {
      name: model.safe_name,
      id: model.to_encoded_id,
    }
  end

  context "when ordering" do
    let(:token) { token_helper.build_token has_global_admin: true }

    let_it_be(:community) { FactoryBot.create :community }

    let_it_be(:collection) { FactoryBot.create :collection, community: }

    let_it_be(:contributor_asimov) do
      create_person_contributor_at(1.day.ago, item_count: 5, given_name: "Isaac", family_name: "Asimov", affiliation: "everything")
    end

    let_it_be(:contributor_salinger) do
      create_person_contributor_at(3.days.ago, item_count: 1, given_name: "J.D.", family_name: "Salinger", affiliation: "fiction")
    end

    let_it_be(:contributor_angelou) do
      create_person_contributor_at(2.days.ago, item_count: 2, given_name: "Maya", family_name: "Angelou", affiliation: "poetry")
    end

    let_it_be(:contributor_shelley) do
      create_person_contributor_at(4.days.ago, item_count: 2, given_name: "Mary", family_name: "Shelley", affiliation: "fiction")
    end

    let_it_be(:keyed_models) do
      {
        asimov: to_rep(contributor_asimov),
        salinger: to_rep(contributor_salinger),
        shelley: to_rep(contributor_shelley),
        angelou: to_rep(contributor_angelou),
      }
    end

    let!(:order) { "RECENT" }
    let(:search_prefix) { nil }

    let!(:graphql_variables) do
      {
        order:,
        prefix: search_prefix,
      }
    end

    let!(:query) do
      <<~GRAPHQL
      query getOrderedContributors($order: ContributorOrder!, $prefix: String) {
        contributors(order: $order, prefix: $prefix) {
          edges {
            node {
              ... on Node { id }
              ... on Contributor { name }
            }
          }

          pageInfo {
            totalCount
            totalUnfilteredCount
          }
        }
      }
      GRAPHQL
    end

    shared_examples_for "an ordered list of contributors" do |order_value, *keys|
      let!(:order) { order_value }

      let_it_be(:expected_shape) do
        shape_for(*keys)
      end

      it "returns contributors in the expected order" do
        expect_request! do |req|
          req.data! expected_shape
        end
      end
    end

    {
      "RECENT" => %i[asimov angelou salinger shelley],
      "OLDEST" => %i[shelley salinger angelou asimov],
      "MOST_CONTRIBUTIONS" => %i[asimov angelou shelley salinger],
      "LEAST_CONTRIBUTIONS" => %i[salinger angelou shelley asimov],
      "NAME_ASCENDING" => %i[angelou asimov salinger shelley],
      "NAME_DESCENDING" => %i[shelley salinger asimov angelou],
      "AFFILIATION_ASCENDING" => %i[asimov salinger shelley angelou],
      "AFFILIATION_DESCENDING" => %i[angelou salinger shelley asimov],
    }.each do |order, keys|
      context "when ordered by #{order}" do
        include_examples "an ordered list of contributors", order, *keys
      end
    end

    context "when filtered by prefix" do
      let(:search_prefix) { "isaa" }
      let(:expected_shape) { shape_for(:asimov) }

      it "returns only the filtered contributor" do
        expect_request! do |req|
          req.data! expected_shape
        end
      end
    end
  end
end

# frozen_string_literal: true

RSpec.describe "Query.permalinks", type: :request do
  context "when ordering" do
    let(:query) do
      <<~GRAPHQL
      query getPermalinkCollection($order: PermalinkOrder) {
        permalinks(order: $order) {
          edges {
            node {
              id
              slug
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

    let(:expected_shape) do
      gql.query do |q|
        q.prop :permalinks do |c|
          c.array :edges do |edges|
            sorted_records.each do |r|
              edges.item do |edge|
                edge.prop :node do |n|
                  n[:id] = r.to_encoded_id
                  n[:slug] = r.system_slug
                end
              end
            end
          end

          c.prop :page_info do |pi|
            pi[:total_count] = sorted_records.size
            pi[:total_unfiltered_count] = sorted_records.size
          end
        end
      end
    end

    let(:graphql_variables) do
      { order:, }
    end

    let(:order) { "RECENT" }

    let_it_be(:records) do
      1.upto(4).map do |n|
        attrs = {
          _at: n.days.ago,
        }

        create_record(**attrs)
      end
    end

    let(:sorted_records) { order_records(records, order:) }

    def create_record(_at:, **attrs)
      Timecop.freeze _at do
        FactoryBot.create(:permalink, **attrs)
      end
    end

    def order_records(records, order: "RECENT")
      case order
      when "OLDEST"
        records.sort_by(&:created_at)
      else
        order_records(records, order: "OLDEST").reverse!
      end
    end

    shared_examples_for "a properly-ordered collection" do
      it "retrieves everything in the right order" do
        expect_request! do |req|
          req.data! expected_shape
        end
      end
    end
  end
end

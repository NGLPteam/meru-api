# frozen_string_literal: true

RSpec.describe "Query.submissions", type: :request do
  context "when ordering" do
    let(:query) do
      <<~GRAPHQL
      query getSubmissionCollection($order: SubmissionOrder) {
        submissions(order: $order) {
          edges {
            node {
              id
              slug

              canUpdate {
                ... AuthorizationResultFragment
              }

              canDestroy {
                ... AuthorizationResultFragment
              }
            }
          }

          pageInfo {
            totalCount
            totalUnfilteredCount
          }
        }
      }

      fragment AuthorizationResultFragment on AuthorizationResult {
        value
        message
        reasons {
          details
          fullMessages
        }
      }
      GRAPHQL
    end

    let(:can_update) { false }
    let(:can_destroy) { false }

    let(:expected_shape) do
      gql.query do |q|
        q.prop :submissions do |c|
          c.array :edges do |edges|
            sorted_records.each do |r|
              edges.item do |edge|
                edge.prop :node do |n|
                  n[:id] = r.to_encoded_id
                  n[:slug] = r.system_slug

                  n.auth_results(can_update:, can_destroy:)
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

    let_it_be(:records, refind: true) do
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
        FactoryBot.create(:submission, **attrs)
      end
    end

    def order_records(records, order: "RECENT")
      case order
      when "DEFAULT"
        order_records(records, order: "RECENT")
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

    shared_examples_for "ordering by each option" do
      context "when ordering DEFAULT" do
        let(:order) { "DEFAULT" }

        include_examples "a properly-ordered collection"
      end

      context "when ordering RECENT" do
        let(:order) { "RECENT" }

        include_examples "a properly-ordered collection"
      end

      context "when ordering OLDEST" do
        let(:order) { "OLDEST" }

        include_examples "a properly-ordered collection"
      end
    end

    as_an_admin_user do
      let(:can_update) { true }
      let(:can_destroy) { false }

      include_examples "ordering by each option"
    end

    as_a_regular_user do
      let(:can_update) { false }
      let(:can_destroy) { false }

      let(:sorted_records) { [] }

      include_examples "ordering by each option"
    end

    as_an_anonymous_user do
      let(:can_update) { false }
      let(:can_destroy) { false }

      let(:sorted_records) { [] }

      include_examples "ordering by each option"
    end
  end
end

# frozen_string_literal: true

RSpec.describe "Query.submissionTargetReviewers", type: :request do
  include_context "depositing authorization testing"

  context "when ordering" do
    let(:query) do
      <<~GRAPHQL
      query getSubmissionTargetReviewerCollection($order: SubmissionTargetReviewerOrder) {
        submissionTargetReviewers(order: $order) {
          edges {
            node {
              id
              slug

              user {
                id
                name
              }

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
        q.prop :submission_target_reviewers do |c|
          c.array :edges do |edges|
            sorted_records.each do |r|
              edges.item do |edge|
                edge.prop :node do |n|
                  n[:id] = r.to_encoded_id
                  n[:slug] = r.system_slug

                  n.prop :user do |u|
                    u[:id] = r.user.to_encoded_id
                    u[:name] = r.user.name
                  end

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

    let_it_be(:users, refind: true) do
      1.upto(4).map do |n|
        FactoryBot.create(:user, name: "User #{n}")
      end
    end

    let_it_be(:records, refind: true) do
      1.upto(4).zip(users).map do |n, user|
        attrs = {
          _at: n.days.ago,
          submission_target:,
          user:
        }

        create_record(**attrs)
      end
    end

    let(:sorted_records) { order_records(records, order:) }

    def create_record(_at:, **attrs)
      Timecop.freeze _at do
        FactoryBot.create(:submission_target_reviewer, **attrs)
      end
    end

    def order_records(records, order: "RECENT")
      case order
      when "DEFAULT"
        records.sort_by { _1.user.default_tuple }
      when "OLDEST"
        records.sort_by(&:created_at)
      else
        order_records(records, order: "OLDEST").reverse!
      end
    end

    around do |example|
      SubmissionTargetReviewer.lock_to!(*records) do
        example.run
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
      let(:can_update) { false }
      let(:can_destroy) { true }

      include_examples "ordering by each option"
    end

    as_a_regular_user do
      let(:can_update) { false }
      let(:can_destroy) { false }

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

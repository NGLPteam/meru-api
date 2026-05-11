# frozen_string_literal: true

RSpec.describe Mutations::ContributorMerge, type: :request, graphql: :mutation do
  mutation_query! <<~GRAPHQL
  mutation ContributorMerge($input: ContributorMergeInput!) {
    contributorMerge(input: $input) {
      source {
        ... ContributorFragment

        mergeTarget {
          ... ContributorFragment
        }
      }

      target {
        ... ContributorFragment

        mergeTarget {
          ... ContributorFragment
        }
      }

      ... ErrorFragment
    }
  }

  fragment ContributorFragment on Contributor {
    claimed
    mergeBusy
    mergeSourceStatus
    mergeTargetStatus

    canDestroy {
      ... AuthorizationResultFragment
    }

    canUpdate {
      ... AuthorizationResultFragment
    }

    canClaim {
      ... AuthorizationResultFragment
    }

    canLinkUser {
      ... AuthorizationResultFragment
    }

    canMergeSource {
      ... AuthorizationResultFragment
    }

    canMergeTarget {
      ... AuthorizationResultFragment
    }

    ... on Node {
      id
    }
  }
  GRAPHQL

  let_it_be(:source_contributor, refind: true) { FactoryBot.create :contributor, :person }
  let_it_be(:target_contributor, refind: true) { FactoryBot.create :contributor, :person }

  let_it_be(:merging_contributor, refind: true) do
    FactoryBot.create(:contributor, :person).tap do |c|
      c.merge_to(target_contributor, enqueue_merge_job: false)
    end
  end

  let(:source) { source_contributor }
  let(:target) { target_contributor }

  let(:target_can_claim) { true }
  let(:target_can_link_user) { true }

  let(:target_auth_results) do
    {
      can_claim: target_can_claim,
      can_link_user: target_can_link_user,
      can_merge_source: true,
      can_merge_target: true
    }
  end

  let_mutation_input!(:source_id) { source.to_encoded_id }
  let_mutation_input!(:target_id) { target.to_encoded_id }

  let(:valid_mutation_shape) do
    gql.mutation(:contributor_merge) do |m|
      m.prop :source do |c|
        c[:id] = source_id
        c[:merge_busy] = true
        c[:merge_source_status] = "MERGING"
        c[:merge_target_status] = "INACTIVE"

        c.auth_results(
          can_claim: false,
          can_destroy: false,
          can_link_user: false,
          can_merge_source: true,
          can_merge_target: true,
          can_update: false
        )

        c.prop :merge_target do |t|
          t[:id] = target_id
          t[:merge_busy] = true
          t[:merge_source_status] = "UNMERGED"
          t[:merge_target_status] = "ACTIVE"

          t.auth_results(**target_auth_results)
        end
      end

      m.prop :target do |c|
        c[:id] = target_id
        c[:merge_busy] = true
        c[:merge_source_status] = "UNMERGED"
        c[:merge_target_status] = "ACTIVE"

        c.auth_results(**target_auth_results)
      end
    end
  end

  let(:empty_mutation_shape) do
    gql.empty_mutation :contributor_merge
  end

  let(:global_error_key) { :_wrong }

  let(:global_error_shape) do
    gql.mutation(:contributor_merge, no_errors: false) do |m|
      m[:source] = be_blank
      m[:target] = be_blank

      m.global_errors do |ge|
        ge.error global_error_key
      end
    end
  end

  shared_examples_for "a global error" do
    it "returns an error" do
      expect_request! do |req|
        req.effect! keep_the_same { source.reload.updated_at }
        req.effect! keep_the_same { target.reload.updated_at }
        req.effect! have_enqueued_no_jobs(Contributors::MergeJob)

        req.data! global_error_shape
      end
    end
  end

  shared_examples_for "a successful mutation" do
    let(:expected_shape) { valid_mutation_shape }

    it "merges the two contributors" do
      expect_request! do |req|
        req.effect! have_enqueued_job(Contributors::MergeJob).with(source, target)

        req.data! expected_shape
      end
    end

    context "when the source and target are already being merged together" do
      before do
        source.merge_to(target, enqueue_merge_job: false)
      end

      let(:global_error_key) { :contributor_merge_in_progress }

      include_examples "a global error"
    end

    context "when the source is the same as the target" do
      let(:target) { source }

      let(:global_error_key) { :contributor_merge_same_contributor }

      include_examples "a global error"
    end

    context "when the source is already being merged into another contributor" do
      let(:source) { merging_contributor }
      let(:target) { source_contributor }

      let(:global_error_key) { :contributor_merge_source_merging }

      include_examples "a global error"
    end

    context "when the target is already being merged into another contributor" do
      let(:target) { merging_contributor }

      let(:global_error_key) { :contributor_merge_target_merging }

      include_examples "a global error"
    end
  end

  shared_examples_for "an unauthorized mutation" do
    let(:expected_shape) { empty_mutation_shape }

    it "is not authorized" do
      expect_request! do |req|
        req.effect! execute_safely

        req.unauthorized!

        req.data! expected_shape
      end
    end
  end

  shared_examples_for "an authorized mutation" do
    include_examples "a successful mutation"
  end

  as_an_admin_user do
    include_examples "an authorized mutation"
  end

  as_a_regular_user do
    include_examples "an unauthorized mutation"
  end

  as_an_anonymous_user do
    include_examples "an unauthorized mutation"
  end
end

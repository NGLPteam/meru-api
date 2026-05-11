# frozen_string_literal: true

RSpec.describe "Query.submissionTargetReviewer", type: :request do
  let(:query) do
    <<~GRAPHQL
    query getSubmissionTargetReviewer($slug: Slug!) {
      submissionTargetReviewer(slug: $slug) {
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

  let_it_be(:community, refind: true) { FactoryBot.create(:community) }

  let_it_be(:collection, refind: true) { FactoryBot.create(:collection, community:) }

  let_it_be(:item_schema_version, refind: true) { FactoryBot.create(:schema_version, :item) }

  let_it_be(:submission_target, refind: true) do
    collection.fetch_submission_target!.tap do |st|
      st.configure!(schema_versions: [item_schema_version], deposit_mode: :direct)
      st.transition_to! :open
    end
  end

  let(:can_update) { false }
  let(:can_destroy) { false }

  let(:found_shape) do
    gql.query do |q|
      q.prop :submission_target_reviewer do |m|
        m[:id] = existing_model.to_encoded_id
        m[:slug] = existing_model.system_slug

        m.prop :user do |u|
          u[:id] = existing_model.user.to_encoded_id
          u[:name] = existing_model.user.name
        end

        m.auth_results(can_update:, can_destroy:)
      end
    end
  end

  let(:blank_shape) do
    gql.query do |q|
      q[:submission_target_reviewer] = be_blank
    end
  end

  let_it_be(:existing_model, refind: true) { FactoryBot.create(:submission_target_reviewer, submission_target:) }

  let(:slug) { existing_model.system_slug }

  let(:graphql_variables) do
    { slug:, }
  end

  shared_examples "a found record" do
    it "finds the SubmissionTargetReviewer" do
      expect_request! do |req|
        req.data! found_shape
      end
    end
  end

  shared_examples "a not found record" do
    it "does not find the SubmissionTargetReviewer" do
      expect_request! do |req|
        req.data! blank_shape
      end
    end
  end

  shared_examples "an existing model lookup" do
    context "when looking for an existing model by slug" do
      include_examples "a found record"
    end
  end

  shared_examples "an authorized lookup" do
    include_examples "an existing model lookup"

    context "when looking for an unknown model by slug" do
      let(:slug) { random_slug }

      include_examples "a not found record"
    end
  end

  as_an_admin_user do
    let(:can_update) { false }
    let(:can_destroy) { true }

    include_examples "an authorized lookup"
  end

  as_a_regular_user do
    let(:can_update) { false }
    let(:can_destroy) { false }

    include_examples "an authorized lookup"
  end

  as_an_anonymous_user do
    let(:can_update) { false }
    let(:can_destroy) { false }

    include_examples "a not found record"
  end
end

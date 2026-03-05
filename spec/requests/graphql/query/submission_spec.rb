# frozen_string_literal: true

RSpec.describe "Query.submission", type: :request do
  let(:query) do
    <<~GRAPHQL
    query getSubmission($slug: Slug!) {
      submission(slug: $slug) {
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

  let(:found_shape) do
    gql.query do |q|
      q.prop :submission do |m|
        m[:id] = existing_model.to_encoded_id
        m[:slug] = existing_model.system_slug

        m.auth_results(can_update:, can_destroy:)
      end
    end
  end

  let(:blank_shape) do
    gql.query do |q|
      q[:submission] = be_blank
    end
  end

  let_it_be(:existing_model, refind: true) { FactoryBot.create :submission }

  let(:slug) { existing_model.system_slug }

  let(:graphql_variables) do
    { slug:, }
  end

  shared_examples "a found record" do
    it "finds the Submission" do
      expect_request! do |req|
        req.data! found_shape
      end
    end
  end

  shared_examples "a not found record" do
    it "does not find the Submission" do
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

  as_a_super_admin_user do
    let(:can_update) { true }
    let(:can_destroy) { true }

    include_examples "an authorized lookup"
  end

  as_an_admin_user do
    let(:can_update) { true }
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

    include_examples "an authorized lookup"
  end
end

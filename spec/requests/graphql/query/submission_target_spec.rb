# frozen_string_literal: true

RSpec.describe "Query.submissionTarget", type: :request do
  graphql_query! <<~GRAPHQL
  query getSubmissionTarget($slug: Slug!) {
    submissionTarget(slug: $slug) {
      id
      slug

      entity {
        __typename

        id
        title
      }

      canUpdate {
        ... AuthorizationResultFragment
      }

      canDestroy {
        ... AuthorizationResultFragment
      }
    }
  }
  GRAPHQL

  let(:can_update) { false }
  let(:can_destroy) { false }

  let(:found_shape) do
    gql.query do |q|
      q.prop :submission_target do |m|
        m[:id] = submission_target.to_encoded_id
        m[:slug] = submission_target.system_slug

        m.prop :entity do |ent|
          ent.typename("Collection")
        end

        m.auth_results(can_update:, can_destroy:)
      end
    end
  end

  let(:blank_shape) do
    gql.query do |q|
      q[:submission_target] = be_blank
    end
  end

  let_it_be(:community, refind: true) { FactoryBot.create(:community, title: "Test Submission Target Community") }

  let_it_be(:collection, refind: true) { FactoryBot.create(:collection, community:, title: "Test Submission Target Collection") }

  let_it_be(:submission_target, refind: true) { FactoryBot.create :submission_target, entity: collection }

  let(:slug) { submission_target.system_slug }

  let(:graphql_variables) do
    { slug:, }
  end

  shared_examples "a found record" do
    it "finds the SubmissionTarget" do
      expect_request! do |req|
        req.data! found_shape
      end
    end
  end

  shared_examples "a not found record" do
    it "does not find the SubmissionTarget" do
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

  shared_examples_for "can see hidden submission targets" do
    context "when looking for a hidden submission target" do
      before do
        collection.visibility = "hidden"
        collection.save!
      end

      include_examples "a found record"
    end
  end

  shared_examples_for "cannot see hidden submission targets" do
    context "when looking for a hidden submission target" do
      before do
        collection.visibility = "hidden"
        collection.save!
      end

      include_examples "a not found record"
    end
  end

  as_an_admin_user do
    let(:can_update) { true }
    let(:can_destroy) { false }

    include_examples "an authorized lookup"
    include_examples "can see hidden submission targets"
  end

  as_a_regular_user do
    let(:can_update) { false }
    let(:can_destroy) { false }

    include_examples "an authorized lookup"
    include_examples "cannot see hidden submission targets"
  end

  as_an_anonymous_user do
    let(:can_update) { false }
    let(:can_destroy) { false }

    include_examples "an authorized lookup"
    include_examples "cannot see hidden submission targets"
  end
end

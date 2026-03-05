# frozen_string_literal: true

RSpec.describe Mutations::SubmissionCreate, type: :request, graphql: :mutation do
  mutation_query! <<~GRAPHQL
  mutation SubmissionCreate($input: SubmissionCreateInput!) {
    submissionCreate(input: $input) {
      submission {
        id
        slug
      }
      ... ErrorFragment
    }
  }
  GRAPHQL

  let(:valid_mutation_shape) do
    gql.mutation(:submission_create) do |m|
      m.prop(:submission) do |s|
        s[:id] = be_an_encoded_id.of_an_existing_model
        s[:slug] = be_an_encoded_slug
      end
    end
  end

  let(:empty_mutation_shape) do
    gql.empty_mutation :submission_create
  end

  shared_examples_for "a successful mutation" do
    let(:expected_shape) { valid_mutation_shape }

    it "creates the submission" do
      expect_request! do |req|
        req.effect! change(Submission, :count).by(1)

        req.data! expected_shape
      end
    end
  end

  shared_examples_for "an unauthorized mutation" do
    let(:expected_shape) { empty_mutation_shape }

    it "is not authorized" do
      expect_request! do |req|
        req.effect! execute_safely
        req.effect! keep_the_same(Submission, :count)

        req.unauthorized!

        req.data! expected_shape
      end
    end
  end

  shared_examples_for "an authorized mutation"
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

# frozen_string_literal: true

RSpec.describe Mutations::SubmissionChangeState, type: :request, graphql: :mutation do
  mutation_query! <<~GRAPHQL
  mutation SubmissionChangeState($input: SubmissionChangeStateInput!) {
    submissionChangeState(input: $input) {
      ... ErrorFragment
    }
  }
  GRAPHQL

  # let_mutation_input!(:foo) { bar }

  let(:valid_mutation_shape) do
    gql.mutation(:submission_change_state) do |m|
    end
  end

  let(:empty_mutation_shape) do
    gql.empty_mutation :submission_change_state
  end

  shared_examples_for "a successful mutation" do
    let(:expected_shape) { valid_mutation_shape }

    it "transitions the submission" do
      expect_request! do |req|

        req.data! expected_shape
      end
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

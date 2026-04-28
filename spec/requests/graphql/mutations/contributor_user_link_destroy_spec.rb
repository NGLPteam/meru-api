# frozen_string_literal: true

RSpec.describe Mutations::ContributorUserLinkDestroy, type: :request, graphql: :mutation do
  mutation_query! <<~GRAPHQL
  mutation ContributorUserLinkDestroy($input: ContributorUserLinkDestroyInput!) {
    contributorUserLinkDestroy(input: $input) {
      destroyed
      destroyedId
      ... ErrorFragment
    }
  }
  GRAPHQL

  let_it_be(:existing_contributor_user_link_attrs) do
    {}
  end

  let_it_be(:existing_contributor_user_link) { FactoryBot.create(:contributor_user_link, **existing_contributor_user_link_attrs) }

  let_mutation_input!(:contributor_user_link_id) { existing_contributor_user_link.to_encoded_id }

  let(:valid_mutation_shape) do
    gql.mutation(:contributor_user_link_destroy) do |m|
      m[:destroyed] = true
      m[:destroyed_id] = be_an_encoded_id.of_a_deleted_model
    end
  end

  let(:empty_mutation_shape) do
    gql.empty_mutation :contributor_user_link_destroy
  end

  shared_examples_for "a successful mutation" do
    let(:expected_shape) { valid_mutation_shape }

    it "destroys the contributor user link" do
      expect_request! do |req|
        req.effect! change(ContributorUserLink, :count).by(-1)

        req.data! expected_shape
      end
    end
  end

  shared_examples_for "an unauthorized mutation" do
    let(:expected_shape) { empty_mutation_shape }

    it "is not authorized" do
      expect_request! do |req|
        req.effect! execute_safely
        req.effect! keep_the_same(ContributorUserLink, :count)

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

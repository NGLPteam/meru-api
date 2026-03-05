# frozen_string_literal: true

RSpec.describe Mutations::CreateOrdering, type: :request, graphql: :mutation do
  mutation_query! <<~GRAPHQL
  mutation createOrdering($input: CreateOrderingInput!) {
    createOrdering(input: $input) {
      ordering {
        id
        name
        identifier
      }

      ... ErrorFragment
    }
  }
  GRAPHQL

  let_it_be(:entity) { FactoryBot.create :collection }

  let!(:identifier) { "test_ordering" }
  let!(:name) { Faker::Lorem.sentence }
  let!(:select_input) do
    {
      direct: "DESCENDANTS",
      links: { contains: true, references: true }
    }
  end

  let!(:filter_input) do
    {
      schemas: []
    }
  end

  let!(:order_input) do
    [
      { path: "entity.updated_at", nulls: "LAST", direction: "DESCENDING" }
    ]
  end

  let!(:mutation_input) do
    {
      entityId: entity.to_encoded_id,
      identifier:,
      name:,
      select: select_input,
      filter: filter_input,
      order: order_input,
    }
  end

  let!(:valid_mutation_shape) do
    gql.mutation(:create_ordering) do |m|
      m.prop :ordering do |o|
        o[:id] = be_present
        o[:name] = name
        o[:identifier] = identifier
      end
    end
  end

  let(:empty_mutation_shape) do
    gql.empty_mutation :create_ordering
  end

  shared_examples_for "an authorized mutation" do
    let(:expected_shape) { valid_mutation_shape }

    context "with a collection" do
      it "works" do
        expect_request! do |req|
          req.effect! change(Ordering, :count).by(1)

          req.data! expected_shape
        end
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

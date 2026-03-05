# frozen_string_literal: true

RSpec.describe Mutations::UpdateOrdering, type: :request, graphql: :mutation do
  mutation_query! <<~GRAPHQL
  mutation updateOrdering($input: UpdateOrderingInput!) {
    updateOrdering(input: $input) {
      ordering {
        id
        name
      }

      ... ErrorFragment
    }
  }
  GRAPHQL

  let_it_be(:ordering, refind: true) { FactoryBot.create :ordering, :collection }

  let_mutation_input!(:ordering_id) { ordering.to_encoded_id }

  let_mutation_input!(:name) { Faker::Lorem.sentence }

  let_mutation_input!(:select) do
    {
      direct: "DESCENDANTS",
      links: { contains: false, references: true }
    }
  end

  let_mutation_input!(:filter) do
    {
      schemas: []
    }
  end

  let_mutation_input!(:order) do
    [
      { path: "entity.updated_at", nulls: "LAST", direction: "DESCENDING" }
    ]
  end

  let(:valid_mutation_shape) do
    gql.mutation :update_ordering do |m|
      m.prop :ordering do |ord|
        ord[:id] = ordering_id
        ord[:name] = name
      end
    end
  end

  let(:empty_mutation_shape) do
    gql.empty_mutation :update_ordering
  end

  shared_examples_for "an authorized mutation" do
    let(:expected_shape) { valid_mutation_shape }

    before do
      clear_enqueued_jobs
    end

    after do
      clear_enqueued_jobs
    end

    context "with a collection" do
      it "works" do
        expect_request! do |req|
          req.effect! change { ordering.reload.updated_at }

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

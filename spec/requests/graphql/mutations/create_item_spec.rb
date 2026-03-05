# frozen_string_literal: true

RSpec.describe Mutations::CreateItem, type: :request, graphql: :mutation, grants_access: true do
  mutation_query! <<~GRAPHQL
  mutation createItem($input: CreateItemInput!) {
    createItem(input: $input) {
      item {
        title
        subtitle
        published {
          value
          precision
        }
        visibility
        summary
        community { id }
        collection { id }

        parent {
          ... on Node { id }
        }
      }

      ... ErrorFragment
    }
  }
  GRAPHQL

  let_it_be(:manager_role) { Role.fetch(:manager) }

  let_it_be(:community, refind: true) { FactoryBot.create :community }
  let_it_be(:collection, refind: true) { FactoryBot.create :collection, community: }
  let_it_be(:parent_item, refind: true) { FactoryBot.create :item, collection: }

  let!(:parent) { collection }

  let_mutation_input!(:title) { Faker::Lorem.sentence }

  let_mutation_input!(:subtitle) { Faker::Lorem.sentence }

  let_mutation_input!(:visibility) { "VISIBLE" }

  let_mutation_input!(:thumbnail) do
    graphql_upload_from "spec", "data", "lorempixel.jpg"
  end

  let_mutation_input!(:summary) { "A test summary" }

  let_mutation_input!(:published) do
    {
      value: "2021-10-31",
      precision: "DAY",
    }
  end

  let_mutation_input!(:parent_id) { parent.to_encoded_id }

  let!(:valid_mutation_shape) do
    gql.mutation :create_item do |m|
      m.prop :item do |itm|
        itm[:title] = title
        itm[:subtitle] = subtitle
        itm[:published] = published
        itm[:visibility] = visibility
        itm[:summary] = summary

        itm.prop :parent do |p|
          p[:id] = parent_id
        end

        itm.prop :collection do |col|
          col[:id] = collection.to_encoded_id
        end

        itm.prop :community do |com|
          com[:id] = community.to_encoded_id
        end
      end
    end
  end

  let(:empty_mutation_shape) do
    gql.empty_mutation :create_item
  end

  shared_examples_for "an authorized mutation" do
    context "with a blank title" do
      let_mutation_input!(:title) { "" }

      let(:expected_shape) do
        gql.mutation :create_item, no_errors: false do |m|
          m[:item] = be_blank

          m.errors do |e|
            e.error :title, :filled?
          end
        end
      end

      it "fails to create the item" do
        expect_request! do |req|
          req.effect! keep_the_same(Item, :count)

          req.data! expected_shape
        end
      end
    end

    context "with an empty string for the summary" do
      let_mutation_input!(:summary) { "" }

      it "creates the item" do
        expect_request! do |req|
          req.effect! change(Item, :count).by(1)

          req.data! valid_mutation_shape
        end
      end
    end

    context "with a null value for the summary" do
      let_mutation_input!(:summary) { nil }

      it "creates the item" do
        expect_request! do |req|
          req.effect! change(Item, :count).by(1)

          req.data! valid_mutation_shape
        end
      end
    end

    context "with a collection as a parent" do
      let(:parent) { collection }

      it "creates the item" do
        expect_request! do |req|
          req.effect! change(Item, :count).by(1)

          req.data! valid_mutation_shape
        end
      end
    end

    context "with an item as a parent" do
      let(:parent) { parent_item }

      it "creates the item" do
        expect_request! do |req|
          req.effect! change(Item, :count).by(1)

          req.data! valid_mutation_shape
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

    context "when the user has been granted manager access to the parent collection" do
      before do
        grant_access! manager_role, on: collection, to: current_user
      end

      include_examples "an authorized mutation"
    end
  end

  as_an_anonymous_user do
    include_examples "an unauthorized mutation"
  end
end

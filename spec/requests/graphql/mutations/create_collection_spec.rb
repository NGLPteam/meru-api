# frozen_string_literal: true

RSpec.describe Mutations::CreateCollection, type: :request, graphql: :mutation do
  mutation_query! <<~GRAPHQL
  mutation createCollection($input: CreateCollectionInput!) {
    createCollection(input: $input) {
      collection {
        title
        visibility
        community { id }

        thumbnail {
          alt
        }

        parent {
          ... on Node { id }
        }
      }

      ... ErrorFragment
    }
  }
  GRAPHQL

  let_it_be(:community, refind: true) { FactoryBot.create :community }
  let_it_be(:parent_collection, refind: true) { FactoryBot.create :collection, community: }

  let!(:parent) { community }

  let(:alt_text) { "Some Alt Text" }

  let_mutation_input!(:parent_id) { parent.to_encoded_id }
  let_mutation_input!(:title) { Faker::Lorem.sentence }
  let_mutation_input!(:visibility) { "VISIBLE" }
  let_mutation_input!(:thumbnail) do
    graphql_upload_from "spec", "data", "lorempixel.jpg", alt: alt_text
  end

  let!(:valid_mutation_shape) do
    gql.mutation(:create_collection) do |m|
      m.prop :collection do |c|
        c[:title] = title
        c[:visibility] = visibility
        c.prop :parent do |p|
          p[:id] = parent_id
        end

        c.prop :community do |com|
          com[:id] = community.to_encoded_id
        end

        c.prop :thumbnail do |tn|
          tn[:alt] = alt_text
        end
      end
    end
  end

  let(:empty_mutation_shape) do
    gql.empty_mutation :create_collection
  end

  shared_examples_for "an authorized mutation" do
    let(:expected_shape) { valid_mutation_shape }

    context "with a community as a parent" do
      let(:parent) { community }

      it "works" do
        expect_request! do |req|
          req.effect! change(Collection, :count).by(1)
          req.effect! change(Layouts::MainInstance, :count).by(1)
          req.effect! have_enqueued_job(Entities::InvalidateAncestorLayoutsJob).once
          req.effect! have_enqueued_job(Entities::InvalidateDescendantLayoutsJob).once
          req.effect! have_enqueued_job(Entities::SyncHierarchiesJob).once

          req.data! expected_shape
        end
      end

      context "when creating with a schema that defines orderings" do
        let_it_be(:simple_community) { FactoryBot.create :schema_version, :simple_community }
        let_it_be(:simple_collection) { FactoryBot.create :schema_version, :simple_collection }

        let_it_be(:community, refind: true) { FactoryBot.create :community, schema_version: simple_community }

        let_mutation_input!(:schema_version_slug) { simple_collection.declaration }

        it "creates the orderings" do
          expect_request! do |req|
            req.effect! change(Collection, :count).by(1)
            req.effect! change(Layouts::MainInstance, :count).by(1)
            req.effect! change(Ordering, :count).by(2)
            req.effect! have_enqueued_job(Entities::InvalidateAncestorLayoutsJob).once
            req.effect! have_enqueued_job(Entities::InvalidateDescendantLayoutsJob).once
            req.effect! have_enqueued_job(Entities::SyncHierarchiesJob).once

            req.data! expected_shape
          end
        end
      end
    end

    context "with a collection as a parent" do
      let(:parent) { parent_collection }

      it "works" do
        expect_request! do |req|
          req.effect! change(Collection, :count).by(1)
          req.effect! change(Layouts::MainInstance, :count).by(1)
          req.effect! have_enqueued_job(Entities::InvalidateAncestorLayoutsJob).once
          req.effect! have_enqueued_job(Entities::InvalidateDescendantLayoutsJob).once
          req.effect! have_enqueued_job(Entities::SyncHierarchiesJob).once

          req.data! expected_shape
        end
      end

      context "with a blank schema_version_slug" do
        let_mutation_input!(:schema_version_slug) { "" }

        let(:expected_shape) do
          gql.mutation(:create_collection, no_errors: false) do |m|
            m[:collection] = be_blank

            m.errors do |e|
              e.error :schema_version_slug, :filled?
            end
          end
        end

        it "fails" do
          expect_request! do |req|
            req.effect! keep_the_same(Collection, :count)

            req.data! expected_shape
          end
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

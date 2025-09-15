# frozen_string_literal: true

RSpec.describe Mutations::PermalinkCreate, type: :request, graphql: :mutation do
  mutation_query! <<~GRAPHQL
  mutation PermalinkCreate($input: PermalinkCreateInput!) {
    permalinkCreate(input: $input) {
      permalink {
        id
        slug
        uri
        kind
        canonical
        permalinkableSlug

        permalinkable {
          __typename

          ... on Community {
            id

            permalinks {
              id
            }

            canonicalPermalink {
              id
            }
          }
        }
      }
      ... ErrorFragment
    }
  }
  GRAPHQL

  let_it_be(:community, refind: true) { FactoryBot.create(:community) }
  let_it_be(:existing_permalink, refind: true) { FactoryBot.create(:permalink, :canon, permalinkable: community) }

  let_mutation_input!(:permalinkable_id) { community.to_encoded_id }
  let_mutation_input!(:uri) { "brand-new-link" }
  let_mutation_input!(:canonical) { true }

  let(:valid_mutation_shape) do
    gql.mutation(:permalink_create) do |m|
      m.prop(:permalink) do |p|
        p[:id] = be_an_encoded_id.of_an_existing_model
        p[:slug] = be_an_encoded_slug
        p[:canonical] = canonical
        p[:kind] = "COMMUNITY"
        p[:uri] = uri
        p[:permalinkable_slug] = community.system_slug

        p.prop(:permalinkable) do |pl|
          pl.typename("Community")
        end
      end
    end
  end

  let(:empty_mutation_shape) do
    gql.empty_mutation :permalink_create
  end

  shared_examples_for "a successful mutation" do
    let(:expected_shape) { valid_mutation_shape }

    it "creates the permalink" do
      expect_request! do |req|
        req.effect! change(Permalink, :count).by(1)
        req.effect! change { community.reload.canonical_permalink.id }.from(existing_permalink.id)
        req.effect! change { community.permalinks.count }.by(1)

        req.data! expected_shape
      end
    end

    context "when the URI is already taken" do
      let_mutation_input!(:uri) { existing_permalink.uri }

      let(:expected_shape) do
        gql.mutation(:permalink_create) do |m|
          m[:permalink] = be_blank

          m.attribute_errors do |ae|
            ae.error :uri, :must_be_unique
          end
        end
      end

      it "fails to create a permalink" do
        expect_request! do |req|
          req.effect! keep_the_same(Permalink, :count)
          req.effect! keep_the_same { community.reload.canonical_permalink.id }
          req.effect! keep_the_same { community.permalinks.count }

          req.data! expected_shape
        end
      end
    end

    context "when the URI is in an invalid format" do
      let_mutation_input!(:uri) { "invalid uri" }

      let(:expected_shape) do
        gql.mutation(:permalink_create) do |m|
          m[:permalink] = be_blank

          m.attribute_errors do |ae|
            ae.error :uri, :must_be_valid_permalink_uri
          end
        end
      end

      it "fails to create a permalink" do
        expect_request! do |req|
          req.effect! keep_the_same(Permalink, :count)
          req.effect! keep_the_same { community.reload.canonical_permalink.id }
          req.effect! keep_the_same { community.permalinks.count }

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
        req.effect! keep_the_same(Permalink, :count)

        req.unauthorized!

        req.data! expected_shape
      end
    end
  end

  as_an_admin_user do
    it_behaves_like "a successful mutation"
  end

  as_an_anonymous_user do
    it_behaves_like "an unauthorized mutation"
  end
end

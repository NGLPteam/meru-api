# frozen_string_literal: true

RSpec.describe Mutations::PermalinkUpdate, type: :request, graphql: :mutation do
  mutation_query! <<~GRAPHQL
  mutation PermalinkUpdate($input: PermalinkUpdateInput!) {
    permalinkUpdate(input: $input) {
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

  let_it_be(:new_permalinkable, refind: true) { FactoryBot.create(:community) }

  let_it_be(:existing_permalink_attrs) do
    {
      uri: "existing-link",
      permalinkable: community,
      canonical: true,
    }
  end

  let_it_be(:existing_permalink) { FactoryBot.create(:permalink, **existing_permalink_attrs) }

  let(:permalinkable) { community }

  let_mutation_input!(:permalink_id) { existing_permalink.to_encoded_id }
  let_mutation_input!(:permalinkable_id) { community.to_encoded_id }
  let_mutation_input!(:uri) { "updated-link" }
  let_mutation_input!(:canonical) { true }

  let(:valid_mutation_shape) do
    gql.mutation(:permalink_update) do |m|
      m.prop(:permalink) do |p|
        p[:id] = permalink_id
        p[:slug] = existing_permalink.system_slug
        p[:canonical] = canonical
        p[:kind] = "COMMUNITY"
        p[:uri] = uri
        p[:permalinkable_slug] = permalinkable.system_slug

        p.prop(:permalinkable) do |pl|
          pl.typename("Community")
        end
      end
    end
  end

  let(:empty_mutation_shape) do
    gql.empty_mutation :permalink_update
  end

  shared_examples_for "a successful mutation" do
    let(:expected_shape) { valid_mutation_shape }

    it "updates the permalink" do
      expect_request! do |req|
        req.effect! change { existing_permalink.reload.uri }.to(uri)

        req.data! expected_shape
      end
    end

    context "when changing the permalinkable" do
      let(:permalinkable) { new_permalinkable }

      let_mutation_input!(:permalinkable_id) { new_permalinkable.to_encoded_id }

      it "updates the permalink's permalinkable" do
        expect_request! do |req|
          req.effect! keep_the_same(Permalink, :count)
          req.effect! change { existing_permalink.reload.uri }.to("updated-link")
          req.effect! change { community.reload.permalinks.count }.by(-1)
          req.effect! change { new_permalinkable.reload.permalinks.count }.by(1)

          req.data! expected_shape
        end
      end
    end

    context "when the URI is already taken" do
      let_it_be(:taken_permalink, refind: true) { FactoryBot.create(:permalink, uri: "updated-link") }

      let(:expected_shape) do
        gql.mutation(:permalink_update) do |m|
          m[:permalink] = be_blank

          m.attribute_errors do |ae|
            ae.error :uri, :must_be_unique
          end
        end
      end

      it "fails to create a permalink" do
        expect_request! do |req|
          req.effect! keep_the_same { existing_permalink.reload.updated_at }
          req.effect! keep_the_same { community.permalinks.count }

          req.data! expected_shape
        end
      end
    end

    context "when the URI is in an invalid format" do
      let_mutation_input!(:uri) { "invalid uri" }

      let(:expected_shape) do
        gql.mutation(:permalink_update) do |m|
          m[:permalink] = be_blank

          m.attribute_errors do |ae|
            ae.error :uri, :must_be_valid_permalink_uri
          end
        end
      end

      it "fails to create a permalink" do
        expect_request! do |req|
          req.effect! keep_the_same { existing_permalink.reload.updated_at }
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

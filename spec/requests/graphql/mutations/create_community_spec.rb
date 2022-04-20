# frozen_string_literal: true

RSpec.describe Mutations::CreateCommunity, type: :request, graphql: :mutation do
  mutation_query! <<~GRAPHQL
  mutation createCommunity($input: CreateCommunityInput!) {
    createCommunity(input: $input) {
      community {
        title
        subtitle
        heroImageLayout

        heroImage {
          alt
          ...IdentificationFragment
        }

        logo {
          alt
          ...IdentificationFragment
        }
      }

      ... ErrorFragment
    }
  }

  fragment IdentificationFragment on ImageIdentification {
    originalFilename
    purpose
  }
  GRAPHQL

  context "as an admin" do
    let(:token) { token_helper.build_token has_global_admin: true }

    let(:alt_text) { "Some Alt Text" }

    let_mutation_input!(:title) { Faker::Lorem.sentence }
    let_mutation_input!(:subtitle) { Faker::Lorem.sentence }
    let_mutation_input!(:hero_image_layout) { "ONE_COLUMN" }
    let_mutation_input!(:hero_image) do
      graphql_upload_from "spec", "data", "lorempixel.jpg", alt: alt_text
    end
    let_mutation_input!(:logo) do
      graphql_upload_from "spec", "data", "lorempixel.jpg", alt: alt_text
    end

    let!(:expected_shape) do
      gql.mutation(:create_community) do |m|
        m.prop :community do |c|
          c[:title] = title
          c[:subtitle] = subtitle
          c[:hero_image_layout] = hero_image_layout

          c.prop :hero_image do |hi|
            hi[:alt] = alt_text
            hi[:original_filename] = "lorempixel.jpg"
            hi[:purpose] = "HERO_IMAGE"
          end

          c.prop :logo do |l|
            l[:alt] = alt_text
            l[:original_filename] = "lorempixel.jpg"
            l[:purpose] = "LOGO"
          end
        end
      end
    end

    it "creates a community" do
      expect_the_default_request.to change(Community, :count).by(1)

      expect_graphql_data expected_shape
    end

    context "with a blank title" do
      let(:title) { "" }

      let!(:expected_shape) do
        gql.mutation(:create_community, no_errors: false) do |m|
          m[:community] = be_blank

          m.errors do |ae|
            ae.error :title, :filled?
          end
        end
      end

      it "fails to create a community" do
        expect_the_default_request.to keep_the_same(Community, :count)

        expect_graphql_data expected_shape
      end
    end
  end
end

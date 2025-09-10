# frozen_string_literal: true

RSpec.describe Mutations::UpdateCommunity, type: :request, graphql: :mutation do
  mutation_query! <<~GRAPHQL
  mutation updateCommunity($input: UpdateCommunityInput!) {
    updateCommunity(input: $input) {
      community {
        title
      }

      ... ErrorFragment
    }
  }
  GRAPHQL

  let_it_be(:old_title) { Faker::Lorem.unique.sentence }

  let(:new_logo) { nil }
  let(:new_title) { Faker::Lorem.unique.sentence }
  let(:new_thumbnail) { nil }

  let_it_be(:community, refind: true) { FactoryBot.create :community, :with_logo, :with_thumbnail, title: old_title }

  let_mutation_input!(:community_id) { community.to_encoded_id }
  let_mutation_input!(:hero_image_layout) { "ONE_COLUMN" }
  let_mutation_input!(:logo) { new_logo }
  let_mutation_input!(:thumbnail) { new_thumbnail }
  let_mutation_input!(:title) { new_title }
  let_mutation_input!(:clear_logo) { false }
  let_mutation_input!(:clear_thumbnail) { false }

  as_an_admin_user do
    let!(:expected_shape) do
      gql.mutation :update_community do |m|
        m.prop :community do |c|
          c[:title] = new_title
        end
      end
    end

    it "updates a community" do
      expect_request! do |req|
        req.effect! change { community.reload.title }.from(old_title).to(new_title)
        req.effect! have_enqueued_job(Entities::RevalidateFrontendCacheJob).at_least(:once)

        req.data! expected_shape
      end
    end

    context "with a blank title" do
      let(:new_title) { "" }

      let!(:expected_shape) do
        gql.mutation :update_community, no_errors: false do |m|
          m[:community] = be_blank

          m.attribute_errors do |ae|
            ae.error :title, :filled?
          end
        end
      end

      it "fails to update the community" do
        expect_request! do |req|
          req.effect! keep_the_same { community.reload.title }

          req.data! expected_shape
        end
      end
    end

    context "when clearing a logo" do
      let_mutation_input!(:clear_logo) { true }

      it "removes the logo" do
        expect_request! do |req|
          req.effect! change { community.reload.logo.present? }.from(true).to(false)
        end
      end

      context "with a new upload as well" do
        let!(:new_logo) do
          graphql_upload_from "spec", "data", "lorempixel.jpg"
        end

        let!(:expected_shape) do
          gql.mutation :update_community, no_errors: false do |m|
            m[:community] = be_blank

            m.attribute_errors do |ae|
              ae.error :logo, :update_and_clear_attachment
            end
          end
        end

        it "fails to change anything" do
          expect_request! do |req|
            req.effect! keep_the_same { community.reload.logo&.id }

            req.data! expected_shape
          end
        end
      end
    end

    context "when clearing a thumbnail" do
      let_mutation_input!(:clear_thumbnail) { true }

      it "removes the thumbnail" do
        expect_request! do |req|
          req.effect! change { community.reload.thumbnail.present? }.from(true).to(false)
        end
      end

      context "with a new upload as well" do
        let!(:new_thumbnail) do
          graphql_upload_from "spec", "data", "lorempixel.jpg"
        end

        let!(:expected_shape) do
          gql.mutation :update_community, no_errors: false do |m|
            m[:community] = be_blank

            m.attribute_errors do |ae|
              ae.error :thumbnail, :update_and_clear_attachment
            end
          end
        end

        it "fails to change anything" do
          expect_request! do |req|
            req.effect! keep_the_same { community.reload.thumbnail.id }

            req.data! expected_shape
          end
        end
      end
    end
  end
end

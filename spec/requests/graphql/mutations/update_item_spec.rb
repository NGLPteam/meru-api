# frozen_string_literal: true

RSpec.describe Mutations::UpdateItem, type: :request, graphql: :mutation do
  mutation_query! <<~GRAPHQL
  mutation updateItem($input: UpdateItemInput!) {
    updateItem(input: $input) {
      item {
        title
        visibility
        visibleAfterAt
        visibleUntilAt
        harvestModificationStatus
        thumbnail {
          alt
        }

        thumbnailMetadata {
          alt
        }
      }

      ... ErrorFragment
    }
  }
  GRAPHQL

  context "as an admin" do
    let(:token) { token_helper.build_token has_global_admin: true }

    let_it_be(:old_title) { Faker::Lorem.unique.sentence }

    let_it_be(:item, refind: true) { FactoryBot.create :item, :with_thumbnail, title: old_title }

    let!(:new_title) { Faker::Lorem.unique.sentence }

    let(:old_visibility) { item.visibility.upcase }
    let(:new_visibility) { old_visibility }

    let(:new_thumbnail) { nil }

    let_mutation_input!(:item_id) { item.to_encoded_id }
    let_mutation_input!(:title) { new_title }
    let_mutation_input!(:visibility) { new_visibility }
    let_mutation_input!(:visible_after_at) { nil }
    let_mutation_input!(:visible_until_at) { nil }
    let_mutation_input!(:thumbnail) { new_thumbnail }
    let_mutation_input!(:clear_thumbnail) { false }
    let_mutation_input!(:maintain_pristine_status) { false }

    let!(:expected_shape) do
      gql.mutation :update_item do |m|
        m.prop :item do |i|
          i[:title] = new_title
          i[:visibility] = new_visibility.upcase
          i[:visible_after_at] = visible_after_at
          i[:visible_until_at] = visible_until_at
        end
      end
    end

    it "updates an item" do
      expect_request! do |req|
        req.effect! change { item.reload.title }.from(old_title).to(new_title)
        req.effect! have_enqueued_job(Entities::RevalidateFrontendCacheJob).at_least(:once)

        req.data! expected_shape
      end
    end

    context "with a blank title" do
      let(:new_title) { "" }

      let!(:expected_shape) do
        gql.mutation :update_item, no_errors: false do |m|
          m[:item] = be_blank

          m.errors do |e|
            e.error :title, :filled?
          end
        end
      end

      it "fails to update the item" do
        expect_request! do |req|
          req.effect! keep_the_same { item.reload.title }

          req.data! expected_shape
        end
      end
    end

    context "when maintain_pristine_status = true" do
      let_mutation_input!(:maintain_pristine_status) { true }

      context "when the item is pristine" do
        before do
          item.pristine_for_harvest!
        end

        it "does nothing" do
          expect_request! do |req|
            req.effect! keep_the_same { item.reload.harvest_modification_status }
          end
        end
      end

      context "when the item has been modified" do
        before do
          item.modified_for_harvest!
        end

        it "restores the pristine status" do
          expect_request! do |req|
            req.effect! change { item.reload.harvest_modification_status }.from("modified").to("pristine")
          end
        end
      end
    end

    context "when setting alt text" do
      let!(:upload_alt_text) { "Upload Alt Text" }

      let!(:new_thumbnail) do
        graphql_upload_from "spec", "data", "lorempixel.jpg", alt: upload_alt_text
      end

      context "with it set on the upload itself" do
        let!(:expected_shape) do
          gql.mutation :update_item do |m|
            m.prop :item do |i|
              i.prop :thumbnail do |tn|
                tn[:alt] = upload_alt_text
              end

              i.prop :thumbnail_metadata do |tm|
                tm[:alt] = upload_alt_text
              end
            end
          end
        end

        it "defers to the alt text set on the meta input" do
          expect_request! do |req|
            req.effect! change { item.reload.thumbnail.id }

            req.data! expected_shape
          end
        end
      end

      context "with explicit metadata set" do
        let!(:meta_alt_text) { "Meta Alt Text" }

        let_mutation_input!(:thumbnail_metadata) { { alt: meta_alt_text } }

        let!(:expected_shape) do
          gql.mutation :update_item do |m|
            m.prop :item do |i|
              i.prop :thumbnail do |tn|
                tn[:alt] = meta_alt_text
              end

              i.prop :thumbnail_metadata do |tm|
                tm[:alt] = meta_alt_text
              end
            end
          end
        end

        it "defers to the expliicit metadata" do
          expect_request! do |req|
            req.effect! change { item.reload.thumbnail.id }

            req.data! expected_shape
          end
        end
      end
    end

    context "when clearing a thumbnail" do
      let!(:clear_thumbnail) { true }

      it "removes the thumbnail" do
        expect_request! do |req|
          req.effect! change { item.reload.thumbnail.present? }.from(true).to(false)
        end
      end

      context "with a new upload" do
        let!(:new_thumbnail) do
          graphql_upload_from "spec", "data", "lorempixel.jpg"
        end

        let!(:expected_shape) do
          gql.mutation :update_item, no_errors: false do |m|
            m[:item] = be_blank

            m.errors do |err|
              err.error :thumbnail, I18n.t("dry_validation.errors.update_and_clear_attachment")
            end
          end
        end

        it "fails to change anything" do
          expect_request! do |req|
            req.effect! keep_the_same { item.reload.thumbnail.id }

            req.data! expected_shape
          end
        end
      end
    end

    context "when hiding" do
      let(:new_visibility) { "HIDDEN" }

      it "hides the item and updates the timestamp" do
        expect_request! do |req|
          req.effect! change { item.reload.visibility }.from("visible").to("hidden")
          req.effect! change { item.reload.hidden_at.present? }.from(false).to(true)
        end
      end
    end

    context "when setting a limited visibility" do
      let(:new_visibility) { "LIMITED" }

      context "with a valid range" do
        let(:visible_after_at) { 1.day.ago.iso8601 }
        let(:visible_until_at) { 1.day.from_now.iso8601 }

        it "updates the visibility" do
          expect_request! do |req|
            req.effect! change { item.reload.visibility }.from("visible").to("limited")

            req.data! expected_shape
          end
        end
      end

      context "with an inverted range" do
        let(:visible_until_at) { 1.day.ago.iso8601 }
        let(:visible_after_at) { 1.day.from_now.iso8601 }

        let!(:expected_shape) do
          gql.mutation :update_item, no_errors: false do |m|
            m[:item] = be_blank

            m.errors do |err|
              err.error :visible_until_at, I18n.t("dry_validation.errors.limited_visibility_inverted_range")
            end
          end
        end

        it "fails to update the visibility" do
          expect_request! do |req|
            req.effect! keep_the_same { item.reload.visibility }

            req.data! expected_shape
          end
        end
      end

      context "with an empty range" do
        let!(:expected_shape) do
          gql.mutation :update_item, no_errors: false do |m|
            m[:item] = be_blank

            m.errors do |err|
              err.error :visibility, I18n.t("dry_validation.errors.limited_visibility_requires_range")
              err.error :visible_after_at, I18n.t("dry_validation.errors.range_required_when_limited_visibility")
              err.error :visible_until_at, I18n.t("dry_validation.errors.limited_visibility_inverted_range")
            end
          end
        end

        it "fails to update the visibility" do
          expect_request! do |req|
            req.effect! keep_the_same { item.reload.visibility }

            req.data! expected_shape
          end
        end
      end
    end
  end
end

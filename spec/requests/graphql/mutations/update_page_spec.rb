# frozen_string_literal: true

RSpec.describe Mutations::UpdatePage, type: :request, graphql: :mutation do
  mutation_query! <<~GRAPHQL
  mutation updatePage($input: UpdatePageInput!) {
    updatePage(input: $input) {
      page {
        title
        slug
      }

      ... ErrorFragment
    }
  }
  GRAPHQL

  let_it_be(:entity, refind: true) { FactoryBot.create :collection }
  let_it_be(:page, refind: true) { FactoryBot.create :page, :with_hero_image, entity: }

  let_it_be(:existing_page, refind: true) { FactoryBot.create :page, :existing, entity: }

  let_mutation_input!(:page_id) { page.to_encoded_id }
  let_mutation_input!(:title) { Faker::Lorem.sentence }
  let_mutation_input!(:slug) { title.parameterize }
  let_mutation_input!(:body) { Faker::Lorem.paragraph }

  let(:valid_mutation_shape) do
    gql.mutation :update_page do |m|
      m.prop :page do |p|
        p[:title] = title
        p[:slug] = slug
      end
    end
  end

  let(:empty_mutation_shape) do
    gql.empty_mutation :update_page
  end

  shared_examples_for "an authorized mutation" do
    let(:expected_shape) { valid_mutation_shape }

    it "updates a page" do
      expect_request! do |req|
        req.effect! change { page.reload.title }.to(title)

        req.data! expected_shape
      end
    end

    context "with an existing slug" do
      let_mutation_input!(:slug) { existing_page.slug }

      let(:expected_shape) do
        gql.mutation :update_page, no_errors: false do |m|
          m[:page] = be_blank

          m.attribute_errors do |ae|
            ae.error :slug, :must_be_unique_slug
          end
        end
      end

      it "fails to update the page" do
        expect_request! do |req|
          req.effect! keep_the_same { page.reload.updated_at }

          req.data! expected_shape
        end
      end
    end

    context "with an invalid slug" do
      let(:slug) { "something Invalid!" }

      let(:expected_shape) do
        gql.mutation :update_page, no_errors: false do |m|
          m[:page] = be_blank

          m.attribute_errors do |ae|
            ae.error :slug, :must_be_slug
          end
        end
      end

      it "fails to update the page" do
        expect_request! do |req|
          req.effect! keep_the_same { page.reload.updated_at }

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

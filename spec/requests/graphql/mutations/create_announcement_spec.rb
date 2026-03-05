# frozen_string_literal: true

RSpec.describe Mutations::CreateAnnouncement, type: :request, graphql: :mutation do
  mutation_query! <<~GRAPHQL
  mutation createAnnouncement($input: CreateAnnouncementInput!) {
    createAnnouncement(input: $input) {
      announcement {
        entity {
          ... on Node { id }
        }
        publishedOn
        header
        teaser
        body
      }

      ... ErrorFragment
    }
  }
  GRAPHQL

  let_it_be(:entity) { FactoryBot.create :collection }

  let_mutation_input!(:entity_id) { entity.to_encoded_id }
  let_mutation_input!(:published_on) { Date.current }
  let_mutation_input!(:header) { "Some Header" }
  let_mutation_input!(:teaser) { "A teaser about the announcement" }
  let_mutation_input!(:body) { "A lot more content about the announcement." }

  let!(:valid_mutation_shape) do
    gql.mutation(:create_announcement) do |m|
      m.prop :announcement do |a|
        a.prop :entity do |e|
          e[:id] = entity_id
        end

        a[:published_on] = published_on.as_json
        a[:header] = header
        a[:teaser] = teaser
        a[:body] = body
      end
    end
  end

  let(:empty_mutation_shape) do
    gql.empty_mutation :create_announcement
  end

  shared_examples_for "an authorized mutation" do
    let(:expected_shape) { valid_mutation_shape }

    context "with a collection" do
      it "creates an announcement" do
        expect_request! do |req|
          req.effect! change(Announcement, :count).by(1)

          req.data! expected_shape
        end
      end

      context "when a required attribute is blank" do
        let_mutation_input!(:body) { "" }

        let(:expected_shape) do
          gql.mutation :create_announcement, no_errors: false do |m|
            m[:announcement] = be_blank

            m.errors do |e|
              e.error :body, :filled?
            end
          end
        end

        it "fails to create the announcement" do
          expect_request! do |req|
            req.effect! keep_the_same(Announcement, :count)

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

# frozen_string_literal: true

RSpec.describe Mutations::UpdateAnnouncement, type: :request, graphql: :mutation do
  mutation_query! <<~GRAPHQL
  mutation updateAnnouncement($input: UpdateAnnouncementInput!) {
    updateAnnouncement(input: $input) {
      announcement {
        id
        publishedOn
        header
        teaser
        body
      }

      ... ErrorFragment
    }
  }
  GRAPHQL

  let!(:old_header) { "Previous Header" }
  let!(:new_header) { "A New Header" }

  let!(:announcement) { FactoryBot.create :announcement, header: old_header }

  let_mutation_input!(:announcement_id) { announcement.to_encoded_id }
  let_mutation_input!(:published_on) { announcement.published_on }
  let_mutation_input!(:header) { new_header }
  let_mutation_input!(:teaser) { announcement.teaser }
  let_mutation_input!(:body) { announcement.body }

  let!(:valid_mutation_shape) do
    gql.mutation(:update_announcement) do |m|
      m.prop :announcement do |a|
        a[:id] = announcement_id
        a[:published_on] = published_on.as_json
        a[:header] = header
        a[:teaser] = teaser
        a[:body] = body
      end
    end
  end

  let(:empty_mutation_shape) do
    gql.empty_mutation :update_announcement
  end

  shared_examples_for "an authorized mutation" do
    let(:expected_shape) { valid_mutation_shape }

    context "with a collection" do
      it "updates an announcement" do
        expect_request! do |req|
          req.effect! change { announcement.reload.header }.from(old_header).to(new_header)

          req.data! expected_shape
        end
      end

      context "when a required attribute is blank" do
        let_mutation_input!(:body) { "" }

        let(:expected_shape) do
          gql.mutation :update_announcement, no_errors: false do |m|
            m[:announcement] = be_blank

            m.errors do |e|
              e.error :body, :filled?
            end
          end
        end

        it "fails to update the announcement" do
          expect_request! do |req|
            req.effect! keep_the_same { announcement.reload.header }

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

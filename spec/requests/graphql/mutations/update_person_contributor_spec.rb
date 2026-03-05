# frozen_string_literal: true

RSpec.describe Mutations::UpdatePersonContributor, type: :request, graphql: :mutation do
  mutation_query! <<~GRAPHQL
  mutation updatePersonContributor($input: UpdatePersonContributorInput!) {
    updatePersonContributor(input: $input) {
      contributor {
        givenName
        orcid
      }

      ... ErrorFragment
    }
  }
  GRAPHQL

  let_it_be(:old_value) { Faker::Lorem.unique.sentence }

  let_it_be(:new_value) { Faker::Lorem.unique.sentence }

  let_it_be(:contributor, refind: true) { FactoryBot.create :contributor, :person, given_name: old_value }

  let_mutation_input!(:contributor_id) { contributor.to_encoded_id }
  let_mutation_input!(:given_name) { new_value }
  let_mutation_input!(:family_name) { contributor.properties.person.family_name }
  let_mutation_input!(:clear_image) { false }

  let!(:valid_mutation_shape) do
    gql.mutation(:update_person_contributor) do |m|
      m.prop :contributor do |c|
        c[:given_name] = new_value
      end
    end
  end

  let(:empty_mutation_shape) do
    gql.empty_mutation :update_person_contributor
  end

  shared_examples_for "an authorized mutation" do
    let(:expected_shape) { valid_mutation_shape }

    it "updates a contributor" do
      expect_request! do |req|
        req.effect! change { contributor.reload.properties.person.given_name }.from(old_value).to(new_value)

        req.data! expected_shape
      end
    end

    context "when clearing an image" do
      let_it_be(:contributor, refind: true) { FactoryBot.create :contributor, :person, :with_image }

      let(:clear_image) { true }

      it "removes the image" do
        expect_request! do |req|
          req.effect! change { contributor.reload.image.present? }.from(true).to(false)
        end
      end
    end

    context "when sending image: nil with an existing image" do
      let_it_be(:contributor, refind: true) { FactoryBot.create :contributor, :person, :with_image }

      let_mutation_input!(:image) { nil }

      it "keeps the image" do
        expect_request! do |req|
          req.effect! keep_the_same { contributor.reload.image.id }
        end
      end
    end

    context "when uploading an image" do
      let_mutation_input!(:image) do
        graphql_upload_from "spec", "data", "lorempixel.jpg"
      end

      it "adds the image" do
        expect_request! do |req|
          req.effect! change { contributor.reload.image.present? }.from(false).to(true)
        end
      end
    end

    context "when updating an ORCID" do
      let_it_be(:orcid_value) { Testing::ORCID.random }

      let_mutation_input!(:orcid) { orcid_value }

      it "updates the contributor" do
        expect_request! do |req|
          req.effect! change { contributor.reload.orcid }.from(nil).to(orcid_value)

          req.data! expected_shape
        end
      end

      context "with an invalid format" do
        let(:orcid_value) { SecureRandom.uuid }

        let!(:expected_shape) do
          gql.mutation(:update_person_contributor, no_errors: false) do |m|
            m[:contributor] = nil

            m.attribute_errors do |eb|
              eb.error :orcid, :must_be_orcid
            end
          end
        end

        it "fails to update the contributor" do
          expect_request! do |req|
            req.effect! keep_the_same { contributor.reload.orcid }

            req.data! expected_shape
          end
        end
      end

      context "with an already-assigned contributor" do
        let_it_be(:existing_contributor, refind: true) { FactoryBot.create :contributor, :person, orcid: orcid_value }

        let!(:expected_shape) do
          gql.mutation(:update_person_contributor, no_errors: false) do |m|
            m[:contributor] = nil

            m.attribute_errors do |eb|
              eb.error :orcid, :must_be_unique_orcid
            end
          end
        end

        it "fails to update the contributor" do
          expect_request! do |req|
            req.effect! keep_the_same { contributor.reload.orcid }

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

# frozen_string_literal: true

RSpec.describe Mutations::UpdateOrganizationContributor, type: :request, graphql: :mutation do
  mutation_query! <<~GRAPHQL
  mutation updateOrganizationContributor($input: UpdateOrganizationContributorInput!) {
    updateOrganizationContributor(input: $input) {
      contributor {
        legalName
      }

      ... ErrorFragment
    }
  }
  GRAPHQL

  let_it_be(:old_value) { Faker::Lorem.unique.sentence }

  let_it_be(:new_value) { Faker::Lorem.unique.sentence }

  let_it_be(:contributor, refind: true) { FactoryBot.create :contributor, :organization, legal_name: old_value }

  let_mutation_input!(:contributor_id) { contributor.to_encoded_id }
  let_mutation_input!(:legal_name) { new_value }
  let_mutation_input!(:clear_image) { false }

  let!(:expected_shape) do
    gql.mutation :update_organization_contributor do |m|
      m.prop :contributor do |c|
        c[:legal_name] = new_value
      end
    end
  end

  let(:empty_mutation_shape) do
    gql.empty_mutation :update_organization_contributor
  end

  shared_examples_for "an authorized mutation" do
    it "updates a contributor" do
      expect_request! do |req|
        req.effect! change { contributor.reload.properties.organization.legal_name }.from(old_value).to(new_value)

        req.data! expected_shape
      end
    end

    context "when clearing and uploading an image at the same time" do
      let!(:contributor) { FactoryBot.create :contributor, :organization, :with_image }

      let_mutation_input!(:image) do
        graphql_upload_from "spec", "data", "lorempixel.jpg"
      end

      let(:clear_image) { true }

      let!(:expected_shape) do
        gql.mutation :update_organization_contributor, no_errors: false do |c|
          c[:contributor] = nil

          c.attribute_errors do |eb|
            eb.error "image", :update_and_clear_attachment
          end
        end
      end

      it "does nothing" do
        expect_request! do |req|
          req.effect! keep_the_same { contributor.reload.image.id }

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

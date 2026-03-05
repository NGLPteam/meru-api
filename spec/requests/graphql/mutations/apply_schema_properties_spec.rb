# frozen_string_literal: true

RSpec.describe Mutations::ApplySchemaProperties, type: :request, simple_v1_hierarchy: true, cv_test_unit: true, graphql: :mutation do
  mutation_query! <<~GRAPHQL
  mutation applySchemaProperties($input: ApplySchemaPropertiesInput!) {
    applySchemaProperties(input: $input) {
      entity {
        ... on Node { id }
      }

      collection { id }

      schemaErrors {
        base
        hint
        path
        message
        metadata
      }

      ... ErrorFragment
    }
  }
  GRAPHQL

  shared_examples_for "an authorized request" do
    context "for a required collection" do
      let_it_be(:schema_version, refind: true) { FactoryBot.create :schema_version, :required_collection }

      let_it_be(:entity, refind: true) { FactoryBot.create(:collection, schema_version:) }

      let_mutation_input!(:entity_id) { entity.to_encoded_id }
      let_mutation_input!(:property_values) do
        { required_field: "text", optional_field: "text" }
      end

      let!(:expected_shape) do
        gql.mutation(:apply_schema_properties) do |m|
          m.prop :entity do |e|
            e[:id] = entity_id
          end

          m.prop :collection do |c|
            c[:id] = entity_id
          end

          m[:schema_errors] = be_blank
        end
      end

      context "with valid properties" do
        it "will save them" do
          expect_the_default_request.to execute_safely

          expect_graphql_data expected_shape
        end
      end

      context "with invalid properties" do
        let!(:property_values) { {} }

        let!(:expected_shape) do
          gql.mutation(:apply_schema_properties, no_errors: false) do |m|
            m[:entity] = be_blank
            m[:collection] = be_blank

            m[:schema_errors] = be_present
          end
        end

        it "will produce errors" do
          expect_the_default_request.to execute_safely

          expect_graphql_data expected_shape
        end
      end
    end

    context "for controlled vocabularies" do
      let_it_be(:schema_version, refind: true) { FactoryBot.create :schema_version, :cvocab_collection }

      let_it_be(:entity, refind: true) { FactoryBot.create(:collection, schema_version:) }

      let_mutation_input!(:entity_id) { entity.to_encoded_id }
      let_mutation_input!(:property_values) do
        {
          items: [
            cv_test_unit_foo.to_encoded_id,
            cv_test_unit_bar.to_encoded_id,
          ],
          item: cv_test_unit_quux.to_encoded_id,
        }
      end

      let!(:expected_shape) do
        gql.mutation(:apply_schema_properties) do |m|
          m.prop :entity do |e|
            e[:id] = entity_id
          end

          m.prop :collection do |c|
            c[:id] = entity_id
          end

          m[:schema_errors] = be_blank
        end
      end

      it "sets references correctly" do
        expect_request! do |req|
          req.effect! change(SchematicCollectedReference, :count).by(2)
          req.effect! change(SchematicScalarReference, :count).by(1)

          req.data! expected_shape
        end
      end
    end
  end

  as_an_admin_user do
    it_behaves_like "an authorized request"
  end
end

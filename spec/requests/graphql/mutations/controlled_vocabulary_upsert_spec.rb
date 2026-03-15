# frozen_string_literal: true

RSpec.describe Mutations::ControlledVocabularyUpsert, type: :request, graphql: :mutation do
  mutation_query! <<~GRAPHQL
  mutation ControlledVocabularyUpsert($input: ControlledVocabularyUpsertInput!) {
    controlledVocabularyUpsert(input: $input) {
      controlledVocabulary {
        id
        slug
        namespace
        identifier
        version
        provides
        name
        description
        itemSet

        items {
          id
          identifier
          label
        }
      }
      ... ErrorFragment
    }
  }
  GRAPHQL

  let(:valid_definition) do
    {
      namespace: "meru.test",
      identifier: "nested",
      name: "Nested Test",
      version: "1.0.0",
      provides: "test_unit",
      items: [
        {
          identifier: "foo",
          label: "Foo",
          children: [
            {
              identifier: "bar",
              label: "Bar",
              children: [
                {
                  identifier: "baz",
                  label: "Baz",
                },
              ]
            }
          ]
        }
      ]
    }
  end

  let_mutation_input!(:select_provider) { false }
  let_mutation_input!(:definition) { valid_definition }

  let(:valid_mutation_shape) do
    gql.mutation(:controlled_vocabulary_upsert) do |m|
      m.prop(:controlled_vocabulary) do |cv|
        cv[:id] = be_an_encoded_id.of_an_existing_model
        cv[:slug] = be_present
        cv[:namespace] = definition[:namespace]
        cv[:identifier] = definition[:identifier]
        cv[:version] = definition[:version]
        cv[:provides] = definition[:provides]
        cv[:name] = definition[:name]

        cv[:item_set] = satisfy("has the right length") do |set|
          set.kind_of?(Array) && set.length == definition[:items].size
        end

        cv.array(:items) do |items|
          definition[:items].each do |item_def|
            items.item do |itm|
              itm[:identifier] = item_def[:identifier]
              itm[:label] = item_def[:label]
            end
          end
        end
      end
    end
  end

  let(:empty_mutation_shape) do
    gql.empty_mutation :controlled_vocabulary_upsert
  end

  shared_examples_for "an authorized mutation" do
    let(:expected_shape) { valid_mutation_shape }

    it "upserts the controlled vocabulary" do
      expect_request! do |req|
        req.effect! change(ControlledVocabulary, :count).by(1)
        req.effect! change(ControlledVocabularyItem, :count).by(3)
        req.effect! keep_the_same { ControlledVocabularySource.providing(definition[:provides]) }

        req.data! expected_shape
      end
    end

    context "when selecting provider" do
      let_mutation_input!(:select_provider) { true }

      it "upserts the controlled vocabulary and automatically sets it as the provider" do
        expect_request! do |req|
          req.effect! change(ControlledVocabulary, :count).by(1)
          req.effect! change(ControlledVocabularyItem, :count).by(3)
          req.effect! change { ControlledVocabularySource.providing(definition[:provides]) }.from(nil).to(a_kind_of(ControlledVocabulary))

          req.data! expected_shape
        end
      end
    end

    context "when providing an invalid definition" do
      let_mutation_input!(:definition) do
        cv_def_not_unique.merge(namespace: "meru.test")
      end

      let(:expected_shape) do
        gql.mutation(:controlled_vocabulary_upsert, no_errors: false) do |m|
          m[:controlled_vocabulary] = be_blank

          m.attribute_errors do |ae|
            ae.error :definition, /not unique/
          end
        end
      end

      it "fails to upsert the controlled vocabulary but returns helpful errors" do
        expect_request! do |req|
          req.effect! keep_the_same(ControlledVocabulary, :count)

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
    it_behaves_like "an authorized mutation"
  end

  as_an_anonymous_user do
    it_behaves_like "an unauthorized mutation"
  end
end

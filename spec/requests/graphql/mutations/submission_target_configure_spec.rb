# frozen_string_literal: true

RSpec.describe Mutations::SubmissionTargetConfigure, type: :request, graphql: :mutation do
  mutation_query! <<~GRAPHQL
  mutation SubmissionTargetConfigure($input: SubmissionTargetConfigureInput!) {
    submissionTargetConfigure(input: $input) {
      submissionTarget {
        id
        slug

        depositMode
        depositTargets {
          id
          depositMode

          entity {
            ... on Collection {
              id
            }

            ... on Item {
              id
            }
          }
        }

        schemaVersions {
          id
        }
      }
      ... ErrorFragment
    }
  }
  GRAPHQL

  let_it_be(:community, refind: true) { FactoryBot.create(:community) }
  let_it_be(:collection, refind: true) { FactoryBot.create(:collection, community:) }
  let_it_be(:item, refind: true) { FactoryBot.create(:item, collection:) }
  let_it_be(:other_item, refind: true) { FactoryBot.create(:item, collection:) }
  let_it_be(:unaffiliated_collection, refind: true) { FactoryBot.create(:collection) }

  let_it_be(:target_entity, refind: true) { collection }

  let_it_be(:community_schema_version, refind: true) { FactoryBot.create(:schema_version, :community) }
  let_it_be(:collection_schema_version, refind: true) { FactoryBot.create(:schema_version, :collection) }

  let(:target_schema_version) { collection_schema_version }

  let(:configurable) { target_entity }

  let_mutation_input!(:configurable_id) { collection.to_encoded_id }

  let_mutation_input!(:deposit_mode) { "DIRECT" }

  let_mutation_input!(:deposit_target_ids) { [] }

  let_mutation_input!(:schema_version_ids) { [target_schema_version.to_encoded_id] }

  let_mutation_input!(:agreement_content) { nil }

  let_mutation_input!(:agreement_required) { false }

  let_mutation_input!(:description) do
    {
      sections: [],
    }
  end

  let(:valid_mutation_shape) do
    gql.mutation(:submission_target_configure) do |m|
      m.prop(:submission_target) do |st|
        st[:id] = be_an_encoded_id.of_an_existing_model
        st[:slug] = be_an_encoded_slug
        st[:deposit_mode] = deposit_mode

        if deposit_mode == "DESCENDANT"
          st[:deposit_targets] = be_present
        else
          st.array(:deposit_targets) do |dts|
            dts.item do |dt|
              dt[:deposit_mode] = "DIRECT"

              dt.prop :entity do |ent|
                ent[:id] = collection.to_encoded_id
              end
            end
          end
        end

        st.array(:schema_versions) do |svs|
          svs.item do |sv|
            sv[:id] = target_schema_version.to_encoded_id
          end
        end
      end
    end
  end

  let(:empty_mutation_shape) do
    gql.empty_mutation :submission_target_configure
  end

  shared_examples_for "a successful mutation" do
    let(:expected_shape) { valid_mutation_shape }

    it "configures the submission target" do
      expect_request! do |req|
        if configurable.kind_of?(SubmissionTarget)
          req.effect! keep_the_same(SubmissionTarget, :count)
        else
          req.effect! change(SubmissionTarget, :count).by(1)
        end

        req.data! expected_shape
      end
    end

    context "when providing a community schema version" do
      let(:target_schema_version) { community_schema_version }

      let(:expected_shape) do
        gql.mutation(:submission_target_configure, no_errors: false) do |m|
          m[:submission_target] = be_blank

          m.attribute_errors do |ae|
            ae.error "schemaVersions.0", :must_be_child_entity_schema
          end
        end
      end

      it "returns an error" do
        expect_request! do |req|
          req.effect! keep_the_same(SubmissionTarget, :count)

          req.data! expected_shape
        end
      end
    end

    context "when deposit mode is DESCENDANT" do
      let(:deposit_mode) { "DESCENDANT" }

      context "with no targets provided" do
        let(:expected_shape) do
          gql.mutation(:submission_target_configure, no_errors: false) do |m|
            m[:submission_target] = be_blank

            m.attribute_errors do |ae|
              ae.error :deposit_targets, :filled?
            end
          end
        end

        it "returns an error" do
          expect_request! do |req|
            req.effect! keep_the_same(SubmissionTarget, :count)

            req.data! expected_shape
          end
        end
      end

      context "with invalid targets provided" do
        let_mutation_input!(:deposit_target_ids) do
          [
            item.to_encoded_id,
            unaffiliated_collection.to_encoded_id,
          ]
        end

        let(:expected_shape) do
          gql.mutation(:submission_target_configure, no_errors: false) do |m|
            m[:submission_target] = be_blank

            m.attribute_errors do |ae|
              ae.error "depositTargets.1", :must_be_descendant
            end
          end
        end

        it "returns an error if deposit targets are not provided" do
          expect_request! do |req|
            req.effect! keep_the_same(SubmissionTarget, :count)

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
    it_behaves_like "a successful mutation"
  end

  as_a_regular_user do
    it_behaves_like "an unauthorized mutation"
  end

  as_an_anonymous_user do
    it_behaves_like "an unauthorized mutation"
  end
end

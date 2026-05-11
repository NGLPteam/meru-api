# frozen_string_literal: true

RSpec.describe Mutations::SubmissionTargetConfigure, type: :request, graphql: :mutation do
  mutation_query! <<~GRAPHQL
  mutation SubmissionTargetConfigure($input: SubmissionTargetConfigureInput!) {
    submissionTargetConfigure(input: $input) {
      submissionTarget {
        id
        slug

        agreementContent
        agreementContentWithFallback
        agreementRequired
        autoApproveDepositors
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

        description {
          internal
          instructions
          sections {
            identifier
            name
            position
            content
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

  let_mutation_input!(:auto_approve_depositors) { false }

  let_mutation_input!(:description) do
    {
      sections: [
        {
          name: "Section 1",
          content: "Content for section 1."
        }
      ],
    }
  end

  let(:expected_agreement_with_fallback_content) { be_blank }

  let(:valid_mutation_shape) do
    gql.mutation(:submission_target_configure) do |m|
      m.prop(:submission_target) do |st|
        st[:id] = be_an_encoded_id.of_an_existing_model
        st[:slug] = be_an_encoded_slug
        st[:deposit_mode] = deposit_mode

        st[:agreement_content] = agreement_content
        st[:agreement_required] = agreement_required
        st[:agreement_content_with_fallback] = expected_agreement_with_fallback_content

        st[:auto_approve_depositors] = auto_approve_depositors

        st.array(:deposit_targets) do |dts|
          if deposit_mode == "DESCENDANT"
            deposit_targets.each do |entity|
              dts.item do |dt|
                dt[:deposit_mode] = "DESCENDANT"

                dt.prop :entity do |ent|
                  ent[:id] = entity.to_encoded_id
                end
              end
            end
          else
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

    context "when agreement required" do
      let(:agreement_required) { true }

      let(:global_agreement) { "Global agreement content." }

      context "with no agreement content provided" do
        let(:expected_agreement_with_fallback_content) { be_blank }

        let(:agreement_content) { nil }

        let(:error_shape) do
          gql.mutation(:submission_target_configure, no_errors: false) do |m|
            m[:submission_target] = be_blank

            m.attribute_errors do |ae|
              ae.error :agreement_content, :filled?
            end
          end
        end

        it "returns an error" do
          expect_request! do |req|
            req.effect! keep_the_same(SubmissionTarget, :count)

            req.data! error_shape
          end
        end

        context "when global config has agreement" do
          let(:expected_agreement_with_fallback_content) { global_agreement }

          before do
            config = GlobalConfiguration.current

            config.depositing.agreement = global_agreement

            config.save!
          end

          it "falls back to global agreement content" do
            expect_request! do |req|
              req.effect! change(SubmissionTarget, :count).by(1)

              req.data! valid_mutation_shape
            end
          end
        end
      end
    end

    context "when deposit mode is DESCENDANT & requires agreement" do
      let(:deposit_mode) { "DESCENDANT" }
      let(:agreement_required) { true }
      let(:agreement_content) { "Agreement content goes here." }

      let(:expected_agreement_with_fallback_content) { agreement_content }

      context "with valid targets provided" do
        let(:deposit_targets) { [item, other_item] }

        let_mutation_input!(:deposit_target_ids) do
          deposit_targets.map(&:to_encoded_id)
        end

        it "configures the submission target with the provided deposit targets" do
          expect_request! do |req|
            req.effect! change(SubmissionDepositTarget, :count).by(2)

            req.data! valid_mutation_shape
          end
        end
      end

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

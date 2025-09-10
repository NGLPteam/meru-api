# frozen_string_literal: true

RSpec.describe Mutations::ReparentEntity, type: :request, graphql: :mutation, disable_ordering_refresh: true do
  mutation_query! <<~GRAPHQL
  mutation reparentEntity($input: ReparentEntityInput!) {
    reparentEntity(input: $input) {
      child {
        ... on Collection {
          parent {
            ... on Community { id }
            ... on Collection { id }
          }
        }

        ... on Item {
          parent {
            ... on Collection { id }
            ... on Item { id }
          }
        }
      }

      ...ErrorFragment
    }
  }
  GRAPHQL

  stub_operation! "frontend.cache.revalidate_entity", as: :revalidate_entity_operation, auto_succeed: true

  let!(:new_parent) { nil }
  let!(:child) { nil }

  let_mutation_input!(:child_id) { child&.to_encoded_id }
  let_mutation_input!(:parent_id) { new_parent&.to_encoded_id }

  as_an_admin_user do
    let_it_be(:community) { FactoryBot.create :community }

    let!(:expected_shape) do
      gql.mutation :reparent_entity, no_errors: true do |m|
        m.prop :child do |c|
          c.prop :parent do |p|
            p[:id] = new_parent.to_encoded_id
          end
        end
      end
    end

    shared_examples_for "a valid mutation" do
      it "changes the contextual parent" do
        expect_request! do |req|
          req.effect! change { child.reload.contextual_parent }.from(old_parent).to(new_parent)

          req.data! expected_shape
        end
      end
    end

    shared_examples_for "moving a leaf to a root" do
      it "clears the old parent" do
        expect_request! do |req|
          req.effect! change { child.reload.parent_id }.from(old_parent.id).to(nil)

          req.data! expected_shape
        end
      end
    end

    context "when moving a subcollection to the top level in a new community" do
      let_it_be(:old_parent) { FactoryBot.create :collection, community: }

      let!(:child) { FactoryBot.create :collection, parent: old_parent, title: "Child" }

      let!(:new_parent) { FactoryBot.create :community, title: "New Parent" }

      it_behaves_like "moving a leaf to a root"
      it_behaves_like "a valid mutation"

      context "when dealing with descendants" do
        let!(:grandchild) { FactoryBot.create :collection, parent: child, title: "Grandchild" }

        let!(:subitem) { FactoryBot.create :item, collection: child }

        it "ensures the hierarchy looks correct" do
          flush_enqueued_jobs

          # sanity check
          aggregate_failures do
            expect(community).to have_descendant grandchild
            expect(community).to have_descendant subitem
          end

          expect_request!(run_jobs: true) do |req|
            req.effect! change { subitem.reload.community.id }.from(community.id).to(new_parent.id)
            req.effect! change { grandchild.reload.community.id }.from(community.id).to(new_parent.id)
            req.effect! change { community.items.exists?(subitem.id) }.from(true).to(false)
            req.effect! change { new_parent.items.exists?(subitem.id) }.from(false).to(true)
            req.effect! change { community.has_descendant?(grandchild) }.from(true).to(false)
            req.effect! change { new_parent.has_descendant?(grandchild) }.from(false).to(true)
          end
        end
      end
    end

    context "when moving to another collection" do
      let_it_be(:old_parent) { FactoryBot.create :collection, community: }

      let!(:child) { FactoryBot.create :collection, parent: old_parent }

      let!(:new_parent) { FactoryBot.create :collection, community: }

      it_behaves_like "a valid mutation"

      it "stays within the same community" do
        expect_request! do |req|
          req.effect! keep_the_same { child.reload.community }

          req.data! expected_shape
        end
      end
    end

    context "when moving an item to another collection" do
      let_it_be(:old_collection) { FactoryBot.create :collection }
      let_it_be(:old_parent) { FactoryBot.create :item, collection: old_collection }

      let!(:child) { FactoryBot.create :item, parent: old_parent }

      let!(:new_parent) { FactoryBot.create :collection }

      it_behaves_like "moving a leaf to a root"
      it_behaves_like "a valid mutation"
    end

    shared_examples_for "a simple failure" do
      it "fails" do
        expect_request! do |req|
          req.effect! keep_the_same { child.reload.parent_id }

          req.data! expected_shape
        end
      end
    end

    context "when moving a parent underneath a child" do
      let!(:child) { FactoryBot.create :collection }
      let!(:new_parent) { FactoryBot.create :collection, parent: child }

      let(:expected_shape) do
        gql.mutation :reparent_entity, no_errors: false do |m|
          m[:child] = be_blank

          m.errors do |err|
            err.error "child", :cannot_own_parent
          end
        end
      end

      include_examples "a simple failure"
    end

    context "when trying to parent one's self" do
      let!(:child) { FactoryBot.create :collection }
      let!(:new_parent) { child }

      let(:expected_shape) do
        gql.mutation :reparent_entity, no_errors: false do |m|
          m[:child] = be_blank

          m.errors do |err|
            err.error "child", :cannot_parent_itself
          end
        end
      end

      include_examples "a simple failure"
    end

    context "when trying to reparent something nonsensical" do
      let!(:child) { FactoryBot.create :collection }
      let!(:new_parent) { FactoryBot.create :item }

      let(:expected_shape) do
        gql.mutation :reparent_entity, no_global_errors: false do |m|
          m[:child] = be_blank

          m.global_errors do |g|
            g.error :unacceptable_edge, message_args: { parent: "item", child: "collection" }
          end
        end
      end

      include_examples "a simple failure"
    end

    context "when moving an item with children to another item" do
      let_it_be(:old_parent) { FactoryBot.create :collection, community: }

      let(:new_grandparent) { FactoryBot.create :collection, community: }

      let!(:item) { FactoryBot.create :item, collection: old_parent }

      let!(:subitem) { FactoryBot.create :item, parent: item }

      let(:child) { item }

      let!(:new_parent) { FactoryBot.create :item, collection: new_grandparent }

      it "maintains the proper hierarchy" do
        flush_enqueued_jobs

        # Sanity check
        aggregate_failures do
          expect(old_parent).to have_descendant(item)
          expect(old_parent).to have_descendant(subitem)
        end

        expect_request!(run_jobs: true) do |req|
          req.effect! change { new_parent.reload.has_descendant?(subitem) }.from(false).to(true)
          req.effect! change { old_parent.reload.has_descendant?(subitem) }.from(true).to(false)
          req.effect! keep_the_same { community.reload.has_descendant?(subitem) }
        end
      end
    end
  end
end

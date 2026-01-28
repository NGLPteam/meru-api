# frozen_string_literal: true

RSpec.describe Collection, type: :model do
  include ActiveJob::TestHelper

  let_it_be(:collection, refind: true) { FactoryBot.create :collection }

  it_behaves_like "an entity with a reference"
  it_behaves_like "an entity with schematic properties", :collection
  it_behaves_like "an entity with schematic references", :collection

  context "when creating a collection" do
    context "with a schema that defines orderings" do
      let_it_be(:community, refind: true) { FactoryBot.create :community, :simple }

      let_it_be(:simple_collection_v1, refind: true) { FactoryBot.create :schema_version, :simple_collection, :v1 }

      it "creates the orderings defined in the schema" do
        expect do
          FactoryBot.create :collection, community:, schema_version: simple_collection_v1
        end.to change(described_class, :count).by(1).and change(Ordering, :count).by(2)
      end
    end
  end

  describe "#largest_child_collection" do
    let!(:collection) { nil }

    let_it_be(:parent_collection) { perform_enqueued_jobs { FactoryBot.create :collection } }
    let_it_be(:subcollection_1) { perform_enqueued_jobs { FactoryBot.create :collection, parent: parent_collection } }
    let_it_be(:subcollection_2) { perform_enqueued_jobs { FactoryBot.create :collection, parent: parent_collection } }
    let_it_be(:subcollection_1_items) { perform_enqueued_jobs { FactoryBot.create_list :item, 2, collection: subcollection_1 } }
    let_it_be(:subcollection_2_items) { perform_enqueued_jobs { FactoryBot.create_list :item, 3, collection: subcollection_2 } }

    it "finds the right subcollection" do
      expect(parent_collection.largest_child_collection).to eq subcollection_2
    end
  end

  context "with inherited orderings", simple_v1_hierarchy: true do
    let_it_be(:collection, refind: true) { create_v1_collection }

    describe "#ordering" do
      it "fetches a known ordering" do
        expect(collection.ordering("items")).to be_a_kind_of Ordering
      end

      it "does not touch the database if the relation is already loaded" do
        collection.orderings.reload

        allow(Ordering).to receive :by_identifier

        expect(collection.ordering("items")).to be_a_kind_of Ordering

        expect(Ordering).not_to have_received :by_identifier
      end

      it "returns nil if not found" do
        expect(collection.ordering("unknown")).to be_nil
      end
    end

    describe "#ordering!" do
      it "fetches a known ordering" do
        expect(collection.ordering!("items")).to be_a_kind_of Ordering
      end

      it "raises an error with an unknown ordering" do
        expect do
          collection.ordering! "unknown"
        end.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end
end

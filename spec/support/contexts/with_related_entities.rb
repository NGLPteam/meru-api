# frozen_string_literal: true

RSpec.shared_context "with related entities" do
  let_it_be(:community, refind: true) { FactoryBot.create(:community) }

  let_it_be(:collection, refind: true) { FactoryBot.create(:collection, community:) }

  let_it_be(:item, refind: true) { FactoryBot.create(:item, collection:) }

  let_it_be(:entity, refind: true) { item }

  shared_examples_for "a model that invalidates its parent entity" do
    let_it_be(:model, refind: true) { FactoryBot.create(described_class.default_factory, entity:) }

    it "triggers an invalidation when the model is updated" do
      expect do
        model.save!
      end.to change { entity.layout_invalidations.count }.by(1)
    end

    it "triggers an invalidation when the model is touched" do
      expect do
        model.touch
      end.to change { entity.layout_invalidations.count }.by(1)
    end

    it "triggers an invalidation when the model is destroyed" do
      expect do
        model.destroy!
      end.to change { entity.layout_invalidations.count }.by(1)
    end

    it "does not trigger an invalidation when it is being destroyed by the entity itself" do
      entity.layout_invalidations.delete_all

      expect do
        entity.destroy!
      end.to keep_the_same(LayoutInvalidation, :count)
        .and change(described_class, :count).by(-1)
    end
  end
end

# frozen_string_literal: true

RSpec.describe EntityVisibilities::Check, type: :operation do
  let_it_be(:community, refind: true) { FactoryBot.create(:community) }
  let_it_be(:collection, refind: true) { FactoryBot.create(:collection, community:) }

  let_it_be(:items_ordering, refind: true) do
    FactoryBot.create(:ordering, identifier: "test_items", entity: collection)
  end

  let_it_be(:entity_visibility, refind: true) { collection.entity_visibility }

  let_it_be(:out_of_sync_item, refind: true) { FactoryBot.create(:item, collection:) }

  let_it_be(:limited_item, refind: true) { FactoryBot.create(:item, collection:) }

  let_it_be(:out_of_sync_entity_visibility, refind: true) do
    out_of_sync_item.entity_visibility
  end

  let_it_be(:limited_entity_visibility, refind: true) do
    limited_item.entity_visibility
  end

  def entry_for(entity)
    collection.find_ordering_entry("test_items", entity)
  end

  it "updates the visibility of entities with mismatched visibility and marks them for asynchronous ordering refresh" do
    # sanity check
    aggregate_failures do
      expect(EntityVisibility.mismatched.count).to eq 0
      expect(items_ordering.visible_count).to eq 2
    end

    expect do
      limited_entity_visibility.tap do |visibility|
        visibility.update_columns(
          visibility: "limited",
          visible_after_at: 5.days.from_now,
          visible_until_at: 10.days.from_now
        )
      end
    end.to change(EntityVisibility.mismatched, :count).by(1)

    expect do
      out_of_sync_entity_visibility.tap do |visibility|
        visibility.update_columns(
          visibility: "hidden",
        )
      end
    end.to change(EntityVisibility.mismatched, :count).by(1)

    expect do
      expect_calling.to succeed.with(2)
    end.to change(EntityVisibility.mismatched, :count).by(-2)
      .and change(OrderingInvalidation, :count).by(2)
      .and keep_the_same(OrderingEntry, :count)
      .and keep_the_same(EntityVisibilityTransition.where(to_state: "visible"), :count)
      .and change(EntityVisibilityTransition.where(to_state: "hidden"), :count).by(2)
      .and change { limited_entity_visibility.reload.state }.from("visible").to("hidden")
      .and change { limited_entity_visibility.active? }.from(true).to(false)
      .and change { out_of_sync_entity_visibility.reload.active? }.from(true).to(false)

    expect do
      OrderingInvalidation.find_each(&:process!)
    end.to change(OrderingEntry, :count).by(-2)
      .and change { entry_for(limited_item).success? }.from(true).to(false)
      .and change { entry_for(out_of_sync_item).success? }.from(true).to(false)
  end
end

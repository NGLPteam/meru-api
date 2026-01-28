# frozen_string_literal: true

RSpec.describe Item, type: :model do
  let_it_be(:item, refind: true) { FactoryBot.create :item }

  it_behaves_like "an entity with a reference"
  it_behaves_like "an entity with schematic properties", :item
  it_behaves_like "an entity with schematic references", :item

  context "with a journal article" do
    let_it_be(:item, refind: true) { FactoryBot.create :item, schema_version: SchemaVersion["nglp:journal_article"] }

    it_behaves_like "an entity with schematic properties", :item
  end
end

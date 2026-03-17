# frozen_string_literal: true

RSpec.describe Entities::IndexSearchDocumentsJob, type: :job do
  let_it_be(:collection, refind: true) { FactoryBot.create(:collection) }

  it "creates a SearchDocument for the entity" do
    expect do
      described_class.perform_now(collection)
    end.to change(EntitySearchDocument, :count).by(1)
  end
end

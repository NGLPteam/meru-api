# frozen_string_literal: true

RSpec.describe Entities::SynchronizeItemsJob, type: :job do
  it_behaves_like "an entity sync job" do
    let!(:entities) { [fixture(:item)] }

    # We get one extra from the global `submission` fixture
    let(:entity_count) { 2 }
  end
end

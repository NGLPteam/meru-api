# frozen_string_literal: true

RSpec.describe Entities::SynchronizeCollectionsJob, type: :job do
  it_behaves_like "an entity sync job" do
    let!(:entities) { [fixture(:collection)] }
  end
end

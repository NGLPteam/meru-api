# frozen_string_literal: true

RSpec.describe Entities::ReprocessLayoutsJob, type: :job do
  let!(:community) { FactoryBot.create(:community) }

  it_behaves_like "a pass-through operation job", "entities.reprocess_layouts" do
    let(:job_arg) { community }
  end
end

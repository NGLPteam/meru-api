# frozen_string_literal: true

RSpec.describe Harvesting::Entities::UpsertJob, type: :job do
  let_it_be(:harvest_entity, refind: true) { FactoryBot.create :harvest_entity }

  it_behaves_like "a pass-through operation job", "harvesting.entities.upsert" do
    let(:job_arg) { harvest_entity }
  end
end

# frozen_string_literal: true

RSpec.describe CacheWarmers::RunJob, type: :job do
  let_it_be(:community, refind: true) { FactoryBot.create(:community) }

  let(:cache_warmer) do
    community.cache_warmer
  end

  it_behaves_like "a pass-through operation job", "cache_warmers.run" do
    let(:job_arg) { cache_warmer }
  end
end

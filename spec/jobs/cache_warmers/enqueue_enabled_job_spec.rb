# frozen_string_literal: true

RSpec.describe CacheWarmers::EnqueueEnabledJob, type: :job do
  let_it_be(:community, refind: true) { FactoryBot.create(:community) }

  let(:cache_warmer) do
    community.cache_warmer
  end

  it "enqueues the job if the cache warmer is enabled" do
    expect do
      described_class.perform_now
    end.to have_enqueued_job(CacheWarmers::RunJob).with(cache_warmer)
  end

  context "when the cache warmer is disabled" do
    before do
      community.cache_warming_off!
    end

    it "does not enqueue the job" do
      expect do
        described_class.perform_now
      end.not_to have_enqueued_job(CacheWarmers::RunJob).with(cache_warmer)
    end
  end

  context "when cache warming is globally disabled" do
    before do
      allow(CachingConfig).to receive(:warming_enabled?).and_return(false)
    end

    it "does not enqueue the job" do
      expect do
        described_class.perform_now
      end.not_to have_enqueued_job(CacheWarmers::RunJob)
    end
  end
end

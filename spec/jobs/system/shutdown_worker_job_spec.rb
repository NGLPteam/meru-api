# frozen_string_literal: true

RSpec.describe System::ShutdownWorkerJob, type: :job do
  before do
    GOOD_JOB_KEEP_RUNNING.make_true
  end

  after do
    GOOD_JOB_KEEP_RUNNING.make_true
  end

  it "signals GoodJob to stop processing new jobs" do
    expect do
      described_class.perform_now
    end.to change(GOOD_JOB_KEEP_RUNNING, :true?).from(true).to(false)
  end
end

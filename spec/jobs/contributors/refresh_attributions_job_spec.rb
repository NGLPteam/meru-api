# frozen_string_literal: true

RSpec.describe Contributors::RefreshAttributionsJob, type: :job do
  it "refresh contributor attributions" do
    expect do
      described_class.perform_now
    end.to execute_safely
  end
end

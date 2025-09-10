# frozen_string_literal: true

RSpec.describe Frontend::PruneRevalidationsJob, type: :job do
  it_behaves_like "a void operation job", "frontend.prune_revalidations"

  it "prunes old revalidations" do
    FactoryBot.create(:frontend_revalidation, created_at: 2.months.ago)
    FactoryBot.create(:frontend_revalidation, created_at: 1.day.ago)

    expect do
      described_class.perform_now
    end.to change(FrontendRevalidation, :count).by(-1)

    expect(FrontendRevalidation.count).to eq(1)
  end
end

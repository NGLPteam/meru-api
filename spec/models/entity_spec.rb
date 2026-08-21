# frozen_string_literal: true

RSpec.describe Entity, type: :model do
  describe ".resync!" do
    it "enqueues a job" do
      expect do
        described_class.resync!
      end.to have_enqueued_job(Entities::SynchronizeAllJob).once
    end
  end

  describe ".sans_attached_thumbnail" do
    it "can find entities missing a thumbnail" do
      expect do
        FactoryBot.create :community
        FactoryBot.create :community, :with_thumbnail
      end.to change(described_class, :count).by(2).and change { described_class.sans_attached_thumbnail.count }.by(1)
    end
  end
end

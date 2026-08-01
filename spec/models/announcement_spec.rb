# frozen_string_literal: true

RSpec.describe Announcement, type: :model do
  include_context "with related entities"

  it_behaves_like "a model that invalidates its parent entity"

  context "when sorting" do
    let!(:entity) { collection }
    let!(:today) { FactoryBot.create :announcement, :today, entity: }
    let!(:yesterday) { FactoryBot.create :announcement, :yesterday, entity: }

    describe ".recent_published" do
      it "returns announcements in the correct order" do
        expect(entity.announcements.recent_published.pluck(:id)).to eq [today.id, yesterday.id]
      end
    end

    describe ".oldest_published" do
      it "returns announcements in the correct order" do
        expect(entity.announcements.oldest_published.pluck(:id)).to eq [yesterday.id, today.id]
      end
    end
  end
end

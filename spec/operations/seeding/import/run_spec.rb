# frozen_string_literal: true

RSpec.describe Seeding::Import::Run, type: :operation, disable_ordering_refresh: true do
  let(:import_path) { Rails.root.join "spec", "data", "sample_import.json" }

  before do
    stub_request(:get, "http://www.sample.com/hero_image.jpg").
      to_return(
        body: Rails.root.join("spec", "data", "lorempixel.jpg").open("r+"),
        headers: {
          "Content-Type": "image/jpeg",
        }
      )
  end

  it "can idempotently import a JSON file" do
    expect do
      expect_calling_with(import_path).to succeed.with communities: [a_kind_of(Community)]
    end.to change(Community, :count).by(1).and change(Collection, :count).by(3).and change(Page, :count).by(1)

    expect do
      expect_calling_with(import_path).to succeed
    end.to keep_the_same(Community, :count).and keep_the_same(Collection, :count).and keep_the_same(Page, :count)
  end
end

# frozen_string_literal: true

RSpec.describe Assets::DecodeDownloadToken, type: :operation do
  let_it_be(:asset, refind: true) { FactoryBot.create :asset }

  let(:expected_mode) { "download" }

  let(:mode) { "download" }
  let(:expires_at) { 2.weeks.ago }

  let(:token_options) do
    {
      expires_at:,
      mode:,
    }
  end

  let!(:token) { asset.encode_download_token!(**token_options) }

  it "decodes regardless of the expiration date" do
    expect_calling_with(asset, token).to succeed.with(expected_mode)
  end

  context "with a view token" do
    let(:mode) { "view" }
    let(:expected_mode) { "view" }

    it "decodes the mode correctly" do
      expect_calling_with(asset, token).to succeed.with(expected_mode)
    end
  end

  context "with an unknown mode" do
    let(:mode) { "unknown_mode" }
    let(:expected_mode) { "view" }

    it "falls back to view mode" do
      expect_calling_with(asset, token).to succeed.with(expected_mode)
    end
  end

  context "with a missing token" do
    let(:token) { nil }

    it "returns a failure" do
      expect_calling_with(asset, token).to monad_fail.with_key(:missing_token)
    end
  end
end

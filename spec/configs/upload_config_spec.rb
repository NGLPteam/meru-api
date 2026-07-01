# frozen_string_literal: true

RSpec.describe UploadConfig do
  let(:bucket) { "test-bucket" }
  let(:cdn_host) { nil }
  let(:mapped_host) { nil }
  let(:remap_signed_url) { false }

  let(:test_key) { "store/test-object" }

  subject(:config) do
    described_class.new(bucket:, cdn_host:, mapped_host:, remap_signed_url:)
  end

  class << self
    def when_trying_to_sign(&)
      describe "when trying to sign a URL" do
        let(:signer) { config.build_signer }

        subject(:signed_url) { signer&.(test_key, expires_in: 3600) }

        instance_eval(&)
      end
    end
  end

  shared_examples_for "a configuration that doesn't remap" do
    it { is_expected.not_to be_able_to_remap_signed }

    its(:remapped_scheme) { is_expected.to be_nil }
    its(:remapped_host) { is_expected.to be_nil }
    its(:remapped_port) { is_expected.to be_nil }
  end

  context "with a fallback configuration" do
    its(:host_mode) { is_expected.to eq(:fallback) }

    when_trying_to_sign do
      it { is_expected.to be_blank }
    end

    include_examples "a configuration that doesn't remap"
  end

  context "with a CDN configuration that remaps" do
    let(:cdn_host) { "https://cdn.example.com" }
    let(:remap_signed_url) { true }

    its(:host) { is_expected.to eq("https://cdn.example.com/") }

    its(:host_mode) { is_expected.to eq(:cdn) }

    it { is_expected.to be_able_to_remap_signed }

    its(:remapped_scheme) { is_expected.to eq("https") }
    its(:remapped_host) { is_expected.to eq("cdn.example.com") }
    its(:remapped_port) { is_expected.to be_nil }

    context "when the CDN host is a non-standard port" do
      let(:cdn_host) { "https://cdn.example.com:8080" }

      its(:remapped_port) { is_expected.to eq(8080) }
    end

    when_trying_to_sign do
      it { is_expected.to start_with "https://cdn.example.com/#{test_key}" }
      it { is_expected.to include "X-Amz-Signature=" }
    end
  end

  context "with a mapped host configuration" do
    let(:mapped_host) { "https://mapped.example.com" }

    its(:host) { is_expected.to eq("https://mapped.example.com/test-bucket/") }

    its(:host_mode) { is_expected.to eq(:mapped) }

    when_trying_to_sign do
      it { is_expected.to start_with "https://mapped.example.com/test-bucket/#{test_key}" }
      it { is_expected.to include "X-Amz-Signature=" }
    end

    include_examples "a configuration that doesn't remap"
  end
end

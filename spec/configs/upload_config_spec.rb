# frozen_string_literal: true

RSpec.describe UploadConfig do
  let(:bucket) { "test-bucket" }
  let(:cdn_host) { nil }
  let(:mapped_host) { nil }

  subject(:config) do
    described_class.new(bucket:, cdn_host:, mapped_host:)
  end

  shared_examples_for "a configuration that uses a custom signer" do
    describe "#build_signer" do
      it "returns an Aws::S3::Presigner instance" do
        expect(subject.build_signer).to be_an_instance_of(UploadConfig::Signer)
      end

      it "generates a valid presigned URL" do
        Timecop.freeze(Time.utc(2026, 1, 1, 12, 0, 0)) do
          actual_url = subject.build_signer.("store/test-object", expires_in: 3600)

          expected_url = Aws::S3::Presigner.new(
            client: subject.s3.build_client_for(subject.host, force_path_style: false)
          ).presigned_url(
            :get_object,
            bucket:,
            key: "store/test-object",
            expires_in: 3600
          )

          expect(actual_url).to eq(expected_url)
          expect(URI.parse(actual_url).query).to include("X-Amz-Signature=")
        end
      end
    end
  end

  context "with a fallback configuration" do
    its(:host_mode) { is_expected.to eq(:fallback) }

    describe "#build_signer" do
      it "returns nil" do
        expect(subject.build_signer).to be_nil
      end
    end
  end

  context "with a CDN configuration" do
    let(:cdn_host) { "https://cdn.example.com" }

    its(:host) { is_expected.to eq("https://cdn.example.com/") }

    its(:host_mode) { is_expected.to eq(:cdn) }

    include_examples "a configuration that uses a custom signer"
  end

  context "with a mapped host configuration" do
    let(:mapped_host) { "https://mapped.example.com" }

    its(:host) { is_expected.to eq("https://mapped.example.com/test-bucket/") }

    its(:host_mode) { is_expected.to eq(:mapped) }

    include_examples "a configuration that uses a custom signer"
  end
end

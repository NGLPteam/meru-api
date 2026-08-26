# frozen_string_literal: true

RSpec.shared_context "with stubbed entity revalidation" do
  before do
    endpoint = Frontend::Cache::EntityRevalidator.endpoint

    now = Time.current.to_i * 1000

    body = { revalidated: true, now:, }.to_json

    headers = { "Content-Type" => "application/json" }

    stub_request(:delete, endpoint)
      .to_return(status: 200, body:, headers:)
  end
end

RSpec.shared_context "with stubbed instance revalidation" do
  include_context "with stubbed entity revalidation"

  before do
    endpoint = Frontend::Cache::InstanceRevalidator.endpoint

    now = Time.current.to_i * 1000

    body = { revalidated: true, now:, }.to_json

    headers = { "Content-Type" => "application/json" }

    stub_request(:delete, endpoint)
      .to_return(status: 200, body:, headers:)
  end
end

RSpec.shared_context "with stubbed revalidation" do
  include_context "with stubbed entity revalidation"
  include_context "with stubbed instance revalidation"
end

# frozen_string_literal: true

RSpec.describe "Status Controller", type: :request do
  include_context "standard requests"

  describe "GET /ping" do
    def make_request!
      get ping_path
    end

    it "pongs back" do
      safely_make_request!

      expect(response).to be_json_content.and be_successful

      expect(response.parsed_body).to include_json(pong: true)
    end
  end

  describe "GET /" do
    def make_request!
      get root_path
    end

    it "renders a simple text status" do
      safely_make_request!

      expect(response).to be_successful

      expect(response.content_type).to match %r{\Atext/plain}

      expect(response.parsed_body).to eq "meru-api v#{MeruAPI::Version}"
    end
  end
end

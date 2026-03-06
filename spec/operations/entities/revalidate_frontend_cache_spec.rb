# frozen_string_literal: true

RSpec.describe Entities::RevalidateFrontendCache, type: :operation do
  let_it_be(:community) { FactoryBot.create(:community) }
  let_it_be(:collection) { FactoryBot.create(:collection, community:) }

  let(:revalidation_url) do
    URI.join(LocationsConfig.frontend_request, "/api/revalidate/entity")
  end

  context "when revalidation is successful" do
    before do
      stub_request(:delete, revalidation_url).to_return(status: 204, body: "{}")
    end

    it "succeeds" do
      expect_calling_with(collection).to succeed
    end
  end

  context "when revalidation fails for any reason" do
    before do
      stub_request(:delete, revalidation_url).to_return(status: 500)
    end

    it "quietly swallows the failure" do
      expect_calling_with(collection).to succeed
    end
  end
end

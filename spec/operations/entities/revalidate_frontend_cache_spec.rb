# frozen_string_literal: true

RSpec.describe Entities::RevalidateFrontendCache, type: :operation do
  let_it_be(:community) { FactoryBot.create(:community) }
  let_it_be(:collection) { FactoryBot.create(:collection, community:) }

  context "when revalidation is successful" do
    stub_operation!("frontend.cache.revalidate_entity", as: :revalidate_actual, auto_succeed: true)

    it "succeeds" do
      expect_calling_with(collection).to succeed
    end
  end

  context "when revalidation fails for any reason" do
    stub_operation!("frontend.cache.revalidate_entity", as: :revalidate_actual, auto_succeed: false)

    before do
      allow(revalidate_actual).to receive(:call).and_return(Dry::Monads.Failure(:any_reason))
    end

    it "quietly swallows the failure" do
      expect_calling_with(collection).to succeed
    end
  end
end

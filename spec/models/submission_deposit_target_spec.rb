# frozen_string_literal: true

RSpec.describe SubmissionDepositTarget, type: :model do
  let_it_be(:community, refind: true) { FactoryBot.create :community }
  let_it_be(:collection, refind: true) { FactoryBot.create :collection, community: }
  let_it_be(:item, refind: true) { FactoryBot.create :item, collection: }

  let_it_be(:submission_target, refind: true) { collection.fetch_submission_target! }

  before do
    submission_target.submission_deposit_targets.delete_all
  end

  it "does not allow an entity that is not the same as or a descendant of the submission target's entity", :aggregate_failures do
    expect(FactoryBot.build(:submission_deposit_target, submission_target:, entity: community)).to be_invalid
    expect(FactoryBot.create(:submission_deposit_target, submission_target:, entity: collection)).to be_valid
    expect(FactoryBot.create(:submission_deposit_target, submission_target:, entity: item)).to be_valid
  end

  it "detects the deposit mode correctly", :aggregate_failures do
    expect(FactoryBot.create(:submission_deposit_target, submission_target:, entity: collection)).to be_direct_deposit
    expect(FactoryBot.create(:submission_deposit_target, submission_target:, entity: item)).to be_descendant_deposit
  end
end

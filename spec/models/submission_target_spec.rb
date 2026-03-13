# frozen_string_literal: true

RSpec.describe SubmissionTarget, type: :model do
  let_it_be(:community, refind: true) { FactoryBot.create :community }
  let_it_be(:collection, refind: true) { FactoryBot.create :collection, community: }
  let_it_be(:item, refind: true) { FactoryBot.create :item, collection: }
  let_it_be(:target_schema_version, refind: true) { FactoryBot.create :schema_version, :collection }

  let_it_be(:submission_target, refind: true) { collection.fetch_submission_target! }

  describe "#has_accepted_agreement?" do
    it "handles anonymous users" do
      expect(submission_target).not_to have_accepted_agreement AnonymousUser.new
    end

    it "handles null users" do
      expect(submission_target).not_to have_accepted_agreement nil
    end

    it "handles un-accepted users" do
      user = FactoryBot.create(:user)

      expect(submission_target).not_to have_accepted_agreement user
    end
  end

  context "when the submission target is descendant" do
    let!(:descendant_submission_target) do
      submission_target.update!(deposit_mode: :descendant)
      submission_target.submission_deposit_targets.create!(entity: item)
    end

    let!(:schema_versions) do
      SubmissionTargetSchemaVersion.where(submission_target:, schema_version: target_schema_version).first_or_create!
    end

    context "and the target is open" do
      before do
        submission_target.transition_to! :open
      end

      it "automatically closes when all descendant deposit targets are removed", :aggregate_failures do
        expect do
          descendant_submission_target.destroy!
        end.to change { submission_target.current_state(force_reload: true) }.from("open").to("closed")
      end
    end
  end
end

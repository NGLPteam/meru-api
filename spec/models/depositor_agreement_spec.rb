# frozen_string_literal: true

RSpec.describe DepositorAgreement, type: :model do
  let_it_be(:community, refind: true) { FactoryBot.create(:community) }

  let_it_be(:collection, refind: true) { FactoryBot.create(:collection, community:) }

  let_it_be(:item_schema_version, refind: true) { FactoryBot.create(:schema_version, :item) }

  let_it_be(:submission_target, refind: true) do
    collection.fetch_submission_target!.tap do |st|
      st.configure!(schema_versions: [item_schema_version], deposit_mode: :direct)
      st.transition_to! :open
    end
  end

  let_it_be(:depositor, refind: true) do
    FactoryBot.create(:user, depositor_on: collection)
  end

  let_it_be(:depositor_agreement, refind: true) do
    FactoryBot.create :depositor_agreement, submission_target:, user: depositor
  end

  subject { depositor_agreement }

  describe "#accept" do
    it "is idempotent" do
      expect do
        expect(subject.accept).to succeed
      end.to change(subject, :state).from("pending").to("accepted")
        .and change(subject, :accepted?).from(false).to(true)
        .and execute_safely

      expect do
        expect(subject.accept).to succeed
      end.to keep_the_same(subject, :state)
        .and keep_the_same(subject, :accepted?)
        .and execute_safely
    end
  end

  describe "#reset" do
    it "has no effect when pending" do
      expect(subject).to be_pending

      expect do
        expect(subject.reset).to succeed
      end.to keep_the_same(subject, :state)
        .and keep_the_same(subject, :pending?)
    end

    context "when the agreement has been accepted" do
      before do
        depositor_agreement.transition_to! :accepted

        subject.reload
      end

      it "resets the state idempotently" do
        expect do
          expect(subject.reset).to succeed
        end.to change(subject, :state).from("accepted").to("pending")
          .and change(subject, :pending?).from(false).to(true)
          .and change(subject, :accepted?).from(true).to(false)

        expect do
          expect(subject.reset).to succeed
        end.to keep_the_same(subject, :state)
          .and keep_the_same(subject, :pending?)
          .and keep_the_same(subject, :accepted?)
      end
    end
  end

  describe ".reset_all!" do
    let_it_be(:accepted_depositor_agreement, refind: true) do
      FactoryBot.create(:depositor_agreement, :accepted, submission_target:)
    end

    it "resets the accepted agreements" do
      expect do
        described_class.reset_all!
      end.to keep_the_same { depositor_agreement.current_state(force_reload: true) }
        .and change { accepted_depositor_agreement.current_state(force_reload: true) }.from("accepted").to("pending")
    end
  end
end

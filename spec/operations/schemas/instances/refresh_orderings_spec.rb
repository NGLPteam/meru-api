# frozen_string_literal: true

RSpec.describe Schemas::Instances::RefreshOrderings, type: :operation do
  let_it_be(:community, refind: true) do
    FactoryBot.create :community
  end

  let_it_be(:journal, refind: true) do
    FactoryBot.create :collection, schema: "nglp:journal", community:
  end

  let_it_be(:volume, refind: true) do
    FactoryBot.create :collection, schema: "nglp:journal_volume", parent: journal
  end

  let_it_be(:issue, refind: true) do
    FactoryBot.create :collection, schema: "nglp:journal_issue", parent: volume
  end

  let_it_be(:article, refind: true) do
    FactoryBot.create :item, schema: "nglp:journal_article", collection: issue
  end

  let(:issue_orderings_count) { 4 }
  let(:article_orderings_count) { 4 }

  before do
    OrderingEntry.delete_all
  end

  context "when refreshing an issue" do
    context "when synchronous" do
      it "only refreshes the right number of orderings" do
        expect do
          expect_calling_with(issue)
        end.to keep_the_same(OrderingInvalidation, :count)
          .and change(OrderingEntry, :count)
      end
    end
  end

  context "when refreshing an article" do
    context "when synchronous" do
      it "only refreshes the right number of orderings" do
        expect do
          expect_calling_with(article).to succeed
        end.to keep_the_same(OrderingInvalidation, :count)
          .and change(OrderingEntry, :count)
      end
    end

    context "when async" do
      around do |example|
        Schemas::Orderings.with_asynchronous_refresh do
          example.run
        end
      end

      it "enqueues the right number of jobs" do
        expect do
          expect_calling_with(article).to succeed
        end.to change(OrderingInvalidation, :count).by(article_orderings_count)
          .and keep_the_same(OrderingEntry, :count)
      end
    end
  end
end

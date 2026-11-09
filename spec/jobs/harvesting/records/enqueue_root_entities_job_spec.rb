# frozen_string_literal: true

RSpec.describe Harvesting::Records::EnqueueRootEntitiesJob, type: :job do
  include ActiveJob::TestHelper

  def actual_entity_for(identifier)
    harvest_record.harvest_entities.find_by!(identifier:).reload_entity
  end

  context "with a valid JATS record" do
    let_it_be(:community, refind: true) { FactoryBot.create :community }

    let_it_be(:target_entity, refind: true) { FactoryBot.create :collection, :journal, community: }

    let_it_be(:harvest_source, refind: true) { FactoryBot.create :harvest_source, :oai, :jats }

    let_it_be(:harvest_attempt, refind: true) { harvest_source.create_attempt!(target_entity:) }

    let_it_be(:harvest_configuration, refind: true) { harvest_attempt.reload_harvest_configuration }

    let_it_be(:sample_record) { Harvesting::Testing::OAI::JATSRecord.find("1576") }

    let_it_be(:harvest_record, refind: true) do
      FactoryBot.create(
        :harvest_record,
        harvest_source:,
        harvest_configuration:,
        sample_record:
      )
    end

    before do
      harvest_record.extract_entities!
    end

    it "can upsert entities from extracted harvest entities, and then upsert assets in a separate asynchronous job" do
      expect do
        described_class.perform_now harvest_record
      end.to execute_safely
        .and change(GoodJob::BatchRecord, :count).by(1)
        .and keep_the_same { harvest_attempt.reload_harvest_attempt_entity_status.try(:upsert_duration_average) }
        .and keep_the_same(HarvestAttemptRecordLink.in_state(:success), :count)
        .and keep_the_same(HarvestAttemptEntityLink.in_state(:success), :count)
        .and have_enqueued_job(Harvesting::Entities::UpsertJob).once

      expect do
        perform_enqueued_jobs
      end.to execute_safely
        .and change(Collection, :count).by(1)
        .and keep_the_same(Item, :count)
        .and keep_the_same { harvest_attempt.reload_harvest_attempt_entity_status.try(:assets_duration_average) }
        .and change { harvest_attempt.reload_harvest_attempt_entity_status.try(:upsert_duration_average) }
        .and keep_the_same(HarvestAttemptRecordLink.in_state(:success), :count)
        .and change(HarvestAttemptEntityLink.in_state(:success), :count).by(1)
        .and have_enqueued_job(Harvesting::Entities::UpsertJob).once

      expect do
        perform_enqueued_jobs
      end.to execute_safely
        .and change(Collection, :count).by(1)
        .and keep_the_same(Item, :count)
        .and keep_the_same { harvest_attempt.reload_harvest_attempt_entity_status.try(:assets_duration_average) }
        .and change { harvest_attempt.reload_harvest_attempt_entity_status.try(:upsert_duration_average) }
        .and keep_the_same(HarvestAttemptRecordLink.in_state(:success), :count)
        .and change(HarvestAttemptEntityLink.in_state(:success), :count).by(1)
        .and have_enqueued_job(Harvesting::Entities::UpsertJob).once

      expect do
        perform_enqueued_jobs
      end.to execute_safely
        .and keep_the_same(Collection, :count)
        .and change(Item, :count).by(1)
        .and change(ItemContribution, :count).by(1)
        .and keep_the_same { harvest_attempt.reload_harvest_attempt_entity_status.try(:assets_duration_average) }
        .and change { harvest_attempt.reload_harvest_attempt_entity_status.try(:upsert_duration_average) }
        .and keep_the_same(HarvestAttemptRecordLink.in_state(:success), :count)
        .and keep_the_same(HarvestAttemptEntityLink.in_state(:success), :count)
        .and change(HarvestAttemptEntityLink.in_state(:upserted), :count).by(1)
        .and have_enqueued_job(Harvesting::Entities::UpsertJob).exactly(0).times
        .and have_enqueued_job(Harvesting::Entities::UpsertAssetsJob).once

      # test extracted entity content
      volume = actual_entity_for("volume-1")
      issue = actual_entity_for("issue-1")
      article = actual_entity_for("meru:oai:jats:1576")

      aggregate_failures do
        expect(volume).to have_schema_version("nglp:journal_volume")
        expect(issue).to have_schema_version("nglp:journal_issue")
        expect(article).to have_schema_version("nglp:journal_article")
        expect(article.published).to eq VariablePrecisionDate.parse("2018-11-03")
        expect(article.doi).to eq "10.36021/jethe.v1i1.14.g5"
        expect(article.read_property_value!("keywords")).to have(5).items
        expect(article.read_property_value!("abstract")).to include_json(
          lang: "en",
          kind: "html",
          content: match(/\A<p>Handwriting is a multisensory process/)
        )
      end

      # We'll also test entity asset upsertion here because it's more effort than it's worth
      # to set up the job tests separately given that we have to repeat everything done here.
      expect do
        perform_enqueued_jobs
      end.to change(Asset.pdf, :count).by(1)
        .and change { harvest_attempt.reload_harvest_attempt_entity_status.try(:assets_duration_average) }
        .and change { article.reload.read_property_value!("pdf_version") }.from(nil).to(a_kind_of(::Asset))
        .and change(HarvestAttemptEntityLink.in_state(:success), :count).by(1)
        .and change(HarvestAttemptRecordLink.in_state(:success), :count).by(1)
    end

    context "when the entities exist but are unlinked" do
      let_it_be(:existing_volume, refind: true) { FactoryBot.create(:collection, :journal_volume, identifier: "volume-1", parent: target_entity, community:) }

      let_it_be(:existing_issue, refind: true) { FactoryBot.create(:collection, :journal_issue, identifier: "issue-1", parent: existing_volume, community:) }

      let_it_be(:existing_article, refind: true) { FactoryBot.create(:item, :journal_article, identifier: "meru:oai:jats:1576", collection: existing_issue) }

      before do
        [existing_volume, existing_issue, existing_article].each do |entity|
          entity.pristine_for_harvest!
        end
      end

      it "links the existing entities" do
        expect do
          described_class.perform_now harvest_record
        end.to execute_safely
          .and keep_the_same(HarvestMessage.error, :count)
          .and change(GoodJob::BatchRecord, :count).by(1)
          .and keep_the_same { harvest_attempt.reload_harvest_attempt_entity_status.try(:upsert_duration_average) }
          .and keep_the_same(HarvestAttemptRecordLink.in_state(:success), :count)
          .and keep_the_same(HarvestAttemptEntityLink.in_state(:success), :count)
          .and have_enqueued_job(Harvesting::Entities::UpsertJob).once

        expect do
          perform_enqueued_jobs
        end.to execute_safely
          .and keep_the_same(HarvestMessage.error, :count)
          .and keep_the_same(Collection, :count)
          .and keep_the_same(Item, :count)
          .and change { existing_volume.harvest_entities.count }.by(1)
          .and keep_the_same { harvest_attempt.reload_harvest_attempt_entity_status.try(:assets_duration_average) }
          .and change { harvest_attempt.reload_harvest_attempt_entity_status.try(:upsert_duration_average) }
          .and keep_the_same(HarvestAttemptRecordLink.in_state(:success), :count)
          .and change(HarvestAttemptEntityLink.in_state(:success), :count).by(1)
          .and have_enqueued_job(Harvesting::Entities::UpsertJob).once

        expect do
          perform_enqueued_jobs
        end.to execute_safely
          .and keep_the_same(HarvestMessage.error, :count)
          .and keep_the_same(Collection, :count)
          .and keep_the_same(Item, :count)
          .and change { existing_issue.harvest_entities.count }.by(1)
          .and keep_the_same { harvest_attempt.reload_harvest_attempt_entity_status.try(:assets_duration_average) }
          .and change { harvest_attempt.reload_harvest_attempt_entity_status.try(:upsert_duration_average) }
          .and keep_the_same(HarvestAttemptRecordLink.in_state(:success), :count)
          .and change(HarvestAttemptEntityLink.in_state(:success), :count).by(1)
          .and have_enqueued_job(Harvesting::Entities::UpsertJob).once

        expect do
          perform_enqueued_jobs
        end.to execute_safely
          .and keep_the_same(HarvestMessage.error, :count)
          .and keep_the_same(Collection, :count)
          .and keep_the_same(Item, :count)
          .and change(ItemContribution, :count).by(1)
          .and change { existing_article.harvest_entities.count }.by(1)
          .and keep_the_same { harvest_attempt.reload_harvest_attempt_entity_status.try(:assets_duration_average) }
          .and change { harvest_attempt.reload_harvest_attempt_entity_status.try(:upsert_duration_average) }
          .and keep_the_same(HarvestAttemptRecordLink.in_state(:success), :count)
          .and keep_the_same(HarvestAttemptEntityLink.in_state(:success), :count)
          .and change(HarvestAttemptEntityLink.in_state(:upserted), :count).by(1)
          .and have_enqueued_job(Harvesting::Entities::UpsertJob).exactly(0).times
          .and have_enqueued_job(Harvesting::Entities::UpsertAssetsJob).once

        expect do
          perform_enqueued_jobs
        end.to change(Asset.pdf, :count).by(1)
          .and keep_the_same(HarvestMessage.error, :count)
          .and change { harvest_attempt.reload_harvest_attempt_entity_status.try(:assets_duration_average) }
          .and change { existing_article.reload.read_property_value!("pdf_version") }.from(nil).to(a_kind_of(::Asset))
          .and change(HarvestAttemptEntityLink.in_state(:success), :count).by(1)
          .and change(HarvestAttemptRecordLink.in_state(:success), :count).by(1)
      end

      context "when the volume and the article are marked no-modify" do
        before do
          existing_volume.modified_for_harvest!
          existing_article.modified_for_harvest!
        end

        it "skips modifications but still executes the whole tree" do
          expect do
            described_class.perform_now harvest_record
          end.to execute_safely
            .and change(GoodJob::BatchRecord, :count).by(1)
            .and keep_the_same(HarvestMessage.error, :count)
            .and keep_the_same { harvest_attempt.reload_harvest_attempt_entity_status.try(:upsert_duration_average) }
            .and keep_the_same(HarvestAttemptRecordLink.in_state(:success), :count)
            .and keep_the_same(HarvestAttemptEntityLink.in_state(:success), :count)
            .and have_enqueued_job(Harvesting::Entities::UpsertJob).once

          # the volume is not modifiable
          expect do
            perform_enqueued_jobs
          end.to execute_safely
            .and keep_the_same(HarvestMessage.error, :count)
            .and change(HarvestMessage.trace.tagged("unmodifiable_entity"), :count).by(1)
            .and keep_the_same(Collection, :count)
            .and keep_the_same(Item, :count)
            .and change { existing_volume.harvest_entities.count }.by(1)
            .and keep_the_same { harvest_attempt.reload_harvest_attempt_entity_status.try(:assets_duration_average) }
            .and keep_the_same { harvest_attempt.reload_harvest_attempt_entity_status.try(:upsert_duration_average) }
            .and keep_the_same(HarvestAttemptRecordLink.in_state(:success), :count)
            .and change(HarvestAttemptEntityLink.in_state(:success), :count).by(1)
            .and have_enqueued_job(Harvesting::Entities::UpsertJob).once

          # the issue is still modifiable
          expect do
            perform_enqueued_jobs
          end.to execute_safely
            .and keep_the_same(HarvestMessage.error, :count)
            .and keep_the_same(HarvestMessage.trace.tagged("unmodifiable_entity"), :count)
            .and keep_the_same(Collection, :count)
            .and keep_the_same(Item, :count)
            .and change { existing_issue.harvest_entities.count }.by(1)
            .and keep_the_same { harvest_attempt.reload_harvest_attempt_entity_status.try(:assets_duration_average) }
            .and change { harvest_attempt.reload_harvest_attempt_entity_status.try(:upsert_duration_average) }
            .and keep_the_same(HarvestAttemptRecordLink.in_state(:success), :count)
            .and change(HarvestAttemptEntityLink.in_state(:success), :count).by(1)
            .and have_enqueued_job(Harvesting::Entities::UpsertJob).once

          # the article is not modifiable
          expect do
            perform_enqueued_jobs
          end.to execute_safely
            .and keep_the_same(HarvestMessage.error, :count)
            .and change(HarvestMessage.trace.tagged("unmodifiable_entity"), :count).by(1)
            .and keep_the_same(Collection, :count)
            .and keep_the_same(Item, :count)
            .and keep_the_same(ItemContribution, :count)
            .and change { existing_article.harvest_entities.count }.by(1)
            .and keep_the_same { harvest_attempt.reload_harvest_attempt_entity_status.try(:assets_duration_average) }
            .and keep_the_same { harvest_attempt.reload_harvest_attempt_entity_status.try(:upsert_duration_average) }
            .and keep_the_same(HarvestAttemptRecordLink.in_state(:success), :count)
            .and keep_the_same(HarvestAttemptEntityLink.in_state(:success), :count)
            .and change(HarvestAttemptEntityLink.in_state(:upserted), :count).by(1)
            .and have_enqueued_job(Harvesting::Entities::UpsertJob).exactly(0).times
            .and have_enqueued_job(Harvesting::Entities::UpsertAssetsJob).exactly(0).times

          expect do
            perform_enqueued_jobs
          end.to execute_safely
            .and keep_the_same(Asset.pdf, :count)
            .and keep_the_same(HarvestMessage.error, :count)
            .and keep_the_same { harvest_attempt.reload_harvest_attempt_entity_status.try(:assets_duration_average) }
            .and keep_the_same { existing_article.reload.read_property_value!("pdf_version") }
            .and keep_the_same(HarvestAttemptEntityLink.in_state(:success), :count)
            .and keep_the_same(HarvestAttemptRecordLink.in_state(:success), :count)
        end
      end
    end
  end

  context "with a valid esploro record with metadata mappings" do
    include_context "harvesting uiowa esploro source"

    let_it_be(:sample_record) { Harvesting::Testing::OAI::EsploroRecord.find("11811152460002771") }

    let_it_be(:harvest_record, refind: true) do
      FactoryBot.create(
        :harvest_record,
        harvest_source:,
        harvest_configuration:,
        sample_record:
      )
    end

    before do
      harvest_record.extract_entities!
    end

    it "extracts the record to the right metadata-mapped parent" do
      expect do
        described_class.perform_now harvest_record
      end.to execute_safely
        .and have_enqueued_job(Harvesting::Entities::UpsertJob).once

      expect do
        perform_enqueued_jobs
      end.to execute_safely
        .and keep_the_same(Collection, :count)
        .and change(Item, :count).by(1)
        .and change(ItemContribution, :count).by(4)
        .and have_enqueued_job(Harvesting::Entities::UpsertAssetsJob).once

      paper = actual_entity_for("meru:oai:esploro:11811152460002771")

      aggregate_failures do
        expect(paper).to have_schema_version("nglp:paper")
        expect(paper.collection).to eq uiowa_ofm
      end

      # we will test that asset job skipping works correctly when the entity is then marked unmodifiable

      paper.modified_for_harvest!

      expect do
        perform_enqueued_jobs
      end.to execute_safely
        .and change(HarvestMessage.trace.tagged("unmodifiable_assets"), :count).by(1)
        .and keep_the_same(Asset, :count)
    end
  end
end

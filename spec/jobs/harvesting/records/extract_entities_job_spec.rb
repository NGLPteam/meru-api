# frozen_string_literal: true

RSpec.describe Harvesting::Records::ExtractEntitiesJob, type: :job do
  context "with a valid JATS record" do
    let_it_be(:target_entity, refind: true) { FactoryBot.create :collection, :journal }

    let_it_be(:harvest_source, refind: true) { FactoryBot.create :harvest_source, :oai, :jats }

    let_it_be(:harvest_attempt, refind: true) { harvest_source.create_attempt!(target_entity:) }

    let_it_be(:harvest_configuration, refind: true) { harvest_attempt.reload_harvest_configuration }

    let_it_be(:sample_record) { Harvesting::Testing::OAI::JATSRecord.find("1576") }

    let_it_be(:harvest_record, refind: true) do
      FactoryBot.create(
        :harvest_record,
        :pending,
        harvest_source:,
        harvest_configuration:,
        sample_record:
      )
    end

    it "can extract harvest entities" do
      expect do
        described_class.perform_now harvest_record
      end.to have_enqueued_job(Harvesting::Records::EnqueueRootEntitiesJob).once
        .and change { harvest_record.reload.status }.from("pending").to("active")
        .and change { harvest_record.reload.entity_count }.from(nil).to(3)
        .and change(HarvestAttemptEntityLink, :count).by(3)
        .and change(HarvestEntity, :count).by(3)
        .and change(HarvestContribution, :count).by(1)
        .and change(HarvestContributor, :count).by(1)
        .and change(Contributor, :count).by(1)
    end
  end

  context "with a valid esploro record with metadata mappings" do
    include_context "harvesting uiowa esploro source"

    let_it_be(:sample_record) { Harvesting::Testing::OAI::EsploroRecord.find("11811152460002771") }

    let_it_be(:harvest_record, refind: true) do
      FactoryBot.create(
        :harvest_record,
        :pending,
        harvest_source:,
        harvest_configuration:,
        sample_record:
      )
    end

    it "extracts the record with the right metadata-mapped parent" do
      expect do
        described_class.perform_now harvest_record
      end.to have_enqueued_job(Harvesting::Records::EnqueueRootEntitiesJob).once
        .and change { harvest_record.reload.status }.from("pending").to("active")
        .and change { harvest_record.reload.entity_count }.from(nil).to(1)
        .and change(HarvestAttemptEntityLink, :count).by(1)
        .and change(HarvestEntity.where(existing_parent: uiowa_ofm), :count).by(1)
        .and change(HarvestContribution, :count).by(4)
        .and change(HarvestContributor, :count).by(4)
        .and change(Contributor, :count).by(4)
    end

    context "when there are conflicts in the metadata mapping" do
      let_it_be(:conflicting_mapping) do
        harvest_source.assign_metadata_mapping!(field: :title, pattern: "^Bedrock Geologic Map", target_entity: uiowa_iwp)
      end

      it "fails to extract the record" do
        expect do
          described_class.perform_now harvest_record
        end.to keep_the_same(HarvestEntity, :count)
          .and have_enqueued_no_jobs(Harvesting::Records::EnqueueRootEntitiesJob)
          .and change { harvest_record.reload.status }.from("pending").to("skipped")
          .and change { harvest_record.reload.entity_count }.from(nil).to(0)
          .and change { harvest_record.skipped.try(:code) }.from(nil).to("metadata_mapping_too_many_found")
          .and change { harvest_record.skipped.try(:reason) }.from(nil).to("too many metadata mappings match")
          .and change(HarvestMessage.error.where(harvest_record:).where_begins_like(message: "Too many metadata"), :count).by(1)
      end
    end

    context "when there is no matching metadata mapping" do
      before do
        HarvestMetadataMapping.where(target_entity: uiowa_ofm).destroy_all
      end

      it "fails to extract the record" do
        expect do
          described_class.perform_now harvest_record
        end.to keep_the_same(HarvestEntity, :count)
          .and have_enqueued_no_jobs(Harvesting::Records::EnqueueRootEntitiesJob)
          .and change { harvest_record.reload.status }.from("pending").to("skipped")
          .and change { harvest_record.reload.entity_count }.from(nil).to(0)
          .and change { harvest_record.skipped.try(:code) }.from(nil).to("metadata_mapping_not_found")
          .and change { harvest_record.skipped.try(:reason) }.from(nil).to("no metadata mappings found")
          .and change(HarvestMessage.error.where(harvest_record:).where_begins_like(message: "Could not find metadata mapping with"), :count).by(1)
      end
    end
  end
end

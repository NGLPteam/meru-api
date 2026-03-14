# frozen_string_literal: true

class HarvestRecord < ApplicationRecord
  include HasEphemeralSystemSlug
  include HasHarvestSource
  include ScopesForIdentifier
  include HasHarvestMetadataFormat
  include HasUnderlyingDataFormat
  include TimestampScopes

  # :nocov:
  include Harvesting::Testing::RecordExtensions if Rails.env.test?
  # :nocov:

  pg_enum! :status, as: :harvest_record_status, allow_blank: false, prefix: :with, suffix: :status, default: "pending"

  belongs_to :harvest_source, inverse_of: :harvest_records
  belongs_to :harvest_configuration, inverse_of: :harvest_records, optional: true

  has_many :harvest_attempt_record_links, inverse_of: :harvest_record, dependent: :delete_all
  has_many :harvest_mapping_record_links, inverse_of: :harvest_record, dependent: :delete_all
  has_many :harvest_set_record_links, inverse_of: :harvest_record, dependent: :delete_all

  has_many :harvest_attempts, through: :harvest_attempt_record_links
  has_many :harvest_mappings, through: :harvest_mapping_record_links
  has_many :harvest_sets, through: :harvest_set_record_links

  has_many :harvest_entities, -> { in_default_order }, inverse_of: :harvest_record, dependent: :destroy
  has_many :harvest_contributions, through: :harvest_entities
  has_many :harvest_contributors, through: :harvest_contributions

  has_many :harvest_messages, inverse_of: :harvest_record, dependent: :destroy

  has_many_readonly :collections, through: :harvest_entities, source: :entity, source_type: "Collection"
  has_many_readonly :items, through: :harvest_entities, source: :entity, source_type: "Item"

  attribute :skipped, Harvesting::Records::Skipped.to_type, default: proc { {} }

  scope :current, -> { where(harvest_attempt: HarvestAttempt.current) }
  scope :previous, -> { where(harvest_attempt: HarvestAttempt.previous) }

  scope :filtered_by_schema_version, ->(version) { where(id: HarvestEntity.filtered_by_schema_version(version).select(:harvest_record_id)) }
  scope :pending, -> { with_pending_status }
  scope :active, -> { with_active_status }
  scope :skipped, -> { with_skipped_status }
  scope :with_entities, -> { where(id: HarvestEntity.select(:harvest_record_id)) }
  scope :sans_entities, -> { where.not(id: HarvestEntity.select(:harvest_record_id)) }

  scope :sans_extracted_scalar_asset, ->(full_path) { with_entities.where.not(id: unscoped.with_extracted_scalar_asset(full_path)) }
  scope :with_extracted_scalar_asset, ->(full_path) { where(id: HarvestEntity.with_extracted_scalar_asset(full_path).select(:harvest_record_id)) }

  scope :in_default_order, -> { in_recent_order }
  scope :in_inverse_order, -> { in_oldest_order }

  # @api private
  attr_accessor :sample_record

  # @see HarvestConfiguration#build_extraction_context
  # @return [Harvesting::Extraction::Context]
  def build_extraction_context
    # :nocov:
    fetch_configuration.build_extraction_context
    # :nocov:
  end

  # @see HarvestMetadataFormat.context_for
  # @return [Harvesting::Metadata::Context]
  def build_metadata_context
    HarvestMetadataFormat.context_for(self)
  end

  # @return [Harvesting::Extraction::RenderContext]
  def build_render_context(metadata_context: build_metadata_context, extraction_context: build_extraction_context)
    Harvesting::Extraction::RenderContext.new(self, metadata_context:, extraction_context:)
  end

  # @api private
  # @return [void]
  def reset_status!
    update_columns(status: "pending", skipped: Harvesting::Records::Skipped.blank)
  end

  # @see Harvesting::Records::ExtractEntities
  # @see Harvesting::Records::EntitiesExtractor
  monadic_operation! def extract_entities(...)
    call_operation("harvesting.records.extract_entities", self, ...)
  end

  def inspect
    "HarvestRecord[:#{metadata_format}](#{identifier.inspect})"
  end

  monadic_operation! def prune_entities(...)
    call_operation("harvesting.records.prune_entities", self, ...)
  end

  # @see Harvesting::Records::UpsertEntities
  # @return [Dry::Monads::Result]
  monadic_operation! def upsert_entities
    call_operation("harvesting.records.upsert_entities", self)
  end

  # @api private
  # @return [Hash]
  def to_sample
    # :nocov:
    changed_at = source_changed_at.iso8601

    metadata_source = Nokogiri::XML(xml_metadata_source, &:noblanks).root.to_xml

    {
      identifier:,
      changed_at:,
      metadata_source:,
    }
    # :nocov:
  end

  # @!group Source Management

  # @!attribute [rw] raw_source
  # @return [String]
  def raw_source
    case harvest_metadata_format.underlying_data_format
    in "json"
      json_source&.to_json
    in "xml"
      xml_source.presence
    end
  end

  def raw_source=(new_raw_source)
    case harvest_metadata_format.underlying_data_format
    in "json"
      self.json_source = accept_json(new_raw_source)
    in "xml"
      self.xml_source = new_raw_source
    end
  end

  # @!attribute [rw] raw_metadata_source
  # @return [String]
  def raw_metadata_source
    case harvest_metadata_format.underlying_data_format
    in "json"
      json_metadata_source&.to_json
    in "xml"
      xml_metadata_source.presence
    end
  end

  def raw_metadata_source=(new_raw_metadata_source)
    case harvest_metadata_format.underlying_data_format
    in "json"
      self.json_metadata_source = accept_json(new_raw_metadata_source)
    in "xml"
      self.xml_metadata_source = new_raw_metadata_source
    end
  end

  # @!endgroup

  private

  # @param [Object, String] data
  def accept_json(data)
    case data
    when String
      Oj.load(data)
    else
      data.as_json
    end
  end

  # @raise [Harvesting::Records::NoConfiguration]
  # @return [HarvestConfiguration]
  def fetch_configuration
    # :nocov:
    raise Harvesting::Records::NoConfiguration.new(self) if harvest_configuration.blank?
    # :nocov:

    harvest_configuration
  end

  class << self
    # Return the most recent {HarvestRecord} instance from the current attempts
    # for a given `sourcelike` that is identified by `identifier`.
    #
    # @param [String, HarvestSource] sourcelike
    # @param [String] identifier
    # @return [HarvestRecord, nil]
    def fetch_for_source(sourcelike, identifier)
      # :nocov:
      for_source(sourcelike).find_by(identifier:)
      # :nocov:
    end

    # Return the most recent {HarvestRecord} instance from the current attempts
    # for a given `sourcelike` that is identified by `identifier`.
    #
    # Raise an error if one is not found.
    #
    # @param [String, HarvestSource] sourcelike
    # @param [String] identifier
    # @raise [Harvesting::Records::Unknown]
    # @return [HarvestRecord]
    def fetch_for_source!(sourcelike, identifier)
      # :nocov:
      for_source(sourcelike).find_by!(identifier:)
    rescue ActiveRecord::RecordNotFound
      raise Harvesting::Records::Unknown, identifier
      # :nocov:
    end
  end
end

# frozen_string_literal: true

# This record functions as a sort of mobile duplicate of {HarvestAttempt}.
#
# It provides a persistent configuration for {HarvestRecord} to grok how
# it should harvest itself, without being tied directly to a specific
# {HarvestAttempt}, since records can be touched by many attempts at a time.
# The latest attempt will store its associated configuration on any
# harvest record it comes across.
#
# The main purpose of this is to allow attempts to be purged without losing
# knowledge of how records should be harvested, and maintaining ties to
# specific {HarvestMapping} and {HarvestSet} records, where applicable.
class HarvestConfiguration < ApplicationRecord
  include GenericInaccessible
  include HasEphemeralSystemSlug
  include HasHarvestMetadataFormat
  include HasHarvestSource
  include HasHarvestingOptions
  include TimestampScopes

  belongs_to :harvest_source, inverse_of: :harvest_configurations
  belongs_to :harvest_mapping, inverse_of: :harvest_configurations, optional: true
  belongs_to :harvest_set, inverse_of: :harvest_configurations, optional: true
  belongs_to :harvest_attempt, inverse_of: :harvest_configuration, optional: true

  belongs_to :target_entity, inverse_of: :harvest_configurations, polymorphic: true

  has_many :harvest_metadata_mappings, through: :harvest_source

  has_many :harvest_records, inverse_of: :harvest_configuration, dependent: :restrict_with_error

  validates :harvest_attempt_id, uniqueness: { if: :harvest_attempt_id? }

  # @return [Harvesting::Extraction::Context]
  def build_extraction_context
    Harvesting::Extraction::Context.new(self)
  end

  # @api private
  # @return [ActiveRecord::Relation<HarvestMetadataMapping>]
  def metadata_mappings_for_extraction
    if use_metadata_mappings?
      harvest_metadata_mappings
    else
      HarvestMetadataMapping.none
    end
  end
end

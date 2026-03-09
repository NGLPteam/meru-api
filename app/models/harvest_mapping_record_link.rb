# frozen_string_literal: true

class HarvestMappingRecordLink < ApplicationRecord
  include GenericInaccessible
  include TimestampScopes

  belongs_to :harvest_mapping, inverse_of: :harvest_mapping_record_links
  belongs_to :harvest_record, inverse_of: :harvest_mapping_record_links
end

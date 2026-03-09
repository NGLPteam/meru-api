# frozen_string_literal: true

class HarvestSetRecordLink < ApplicationRecord
  include GenericInaccessible
  include TimestampScopes

  belongs_to :harvest_set, inverse_of: :harvest_set_record_links
  belongs_to :harvest_record, inverse_of: :harvest_set_record_links
end

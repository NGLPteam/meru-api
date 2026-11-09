# frozen_string_literal: true

class HarvestMessage < ApplicationRecord
  include HasEphemeralSystemSlug
  include TimestampScopes

  pg_enum! :level, as: :harvest_message_level

  belongs_to :harvest_source, inverse_of: :harvest_messages, optional: true
  belongs_to :harvest_attempt, inverse_of: :harvest_messages, optional: true
  belongs_to :harvest_mapping, inverse_of: :harvest_messages, optional: true
  belongs_to :harvest_record, inverse_of: :harvest_messages, optional: true
  belongs_to :harvest_entity, inverse_of: :harvest_messages, optional: true

  scope :in_default_order, -> { order(at: :desc) }

  scope :severity, ->(level) { where(arel_table[:level].lteq(Harvesting::Types::MessageLevelLimit[level])) }

  scope :for_record_format, ->(format) { in_default_order.where(harvest_record_id: HarvestRecord.for_metadata_format(format).select(:id)) }

  class << self
    def tagged(*tags)
      encoded = arel_encode_text_array(*tags)

      contains = arel_infix("@>", arel_table[:tags], encoded)

      where(contains)
    end
  end
end

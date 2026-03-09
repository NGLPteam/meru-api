# frozen_string_literal: true

# A staged contribution that will generate a matching {Contribution} record.
class HarvestContribution < ApplicationRecord
  include GenericInaccessible
  include TimestampScopes

  belongs_to :harvest_contributor, inverse_of: :harvest_contributions
  belongs_to :harvest_entity, inverse_of: :harvest_contributions
  belongs_to :role, class_name: "ControlledVocabularyItem", inverse_of: :harvest_contributions, optional: true

  has_one :harvest_record, through: :harvest_entity

  scope :by_record, ->(record) { joins(:harvest_record).where(harvest_records: { id: record }) }

  # @return [Hash]
  def to_attach_options
    {
      role:,
      inner_position:,
      outer_position:,
    }
  end
end

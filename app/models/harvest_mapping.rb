# frozen_string_literal: true

class HarvestMapping < ApplicationRecord
  include HarvestAttemptable
  include HasEphemeralSystemSlug
  include HasHarvestMetadataFormat
  include HasHarvestSource
  include HasHarvestingOptions
  include TimestampScopes

  pg_enum! :mode, as: :harvest_schedule_mode, null: false, default: :manual

  belongs_to :harvest_source, inverse_of: :harvest_mappings
  belongs_to :harvest_set, inverse_of: :harvest_mappings, optional: true
  belongs_to :target_entity, inverse_of: :harvest_mappings, polymorphic: true

  has_one_readonly :latest_harvest_attempt_link, inverse_of: :harvest_mapping

  has_many :harvest_attempts, inverse_of: :harvest_mapping, dependent: :destroy

  has_many :harvest_configurations, inverse_of: :harvest_mapping, dependent: :nullify

  has_many :harvest_messages, inverse_of: :harvest_mapping, dependent: :nullify

  has_many :harvest_mapping_record_links, inverse_of: :harvest_mapping, dependent: :delete_all

  has_many :harvest_records, through: :harvest_mapping_record_links

  scope :by_target, ->(entity) { where(target_entity: entity) }
  scope :by_set, ->(set) { where(harvest_set: set) }

  scope :in_default_order, -> { in_recent_order }
  scope :in_inverse_order, -> { in_oldest_order }

  before_validation :inherit_metadata_format!
  before_validation :parse_frequency_expression!

  after_save :schedule_attempts!

  # @see Harvesting::Mappings::AttemptsScheduler
  # @see Harvesting::Mappings::ScheduleAttempts
  monadic_operation! def schedule_attempts
    call_operation("harvesting.mappings.schedule_attempts", self)
  end

  private

  # @return [void]
  def inherit_metadata_format!
    self.metadata_format ||= harvest_source&.metadata_format
  end

  # @return [void]
  def parse_frequency_expression!
    call_operation("harvesting.schedules.parse", frequency_expression) do |m|
      m.success do |parsed|
        assign_attributes(parsed)
      end

      # simplecov:disable
      m.failure(:invalid_frequency_expression) do |_, error_keys|
        Array(error_keys).each do |error_key|
          message = I18n.t(error_key, scope: "dry_validation.errors", raise: false)

          errors.add :frequency_expression, message
        end
      end

      m.failure do
        errors.add :frequency_expression, "is invalid"
      end
      # simplecov:enable
    end

    self.schedule_changed_at = Time.current if frequency_expression_changed? || mode_changed? || frequency_changed? || schedule_data_changed?
  end
end

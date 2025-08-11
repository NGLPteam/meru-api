# frozen_string_literal: true

class HarvestAttempt < ApplicationRecord
  include HarvestConfigurable
  include HasEphemeralSystemSlug
  include HasHarvestErrors
  include HasHarvestMetadataFormat
  include HasHarvestSource
  include TimestampScopes
  include UsesStatesman

  pg_enum! :mode, as: :harvest_schedule_mode, null: false, default: :manual

  has_state_machine! machine_class: Harvesting::Attempts::StateMachine

  belongs_to :target_entity, inverse_of: :harvest_attempts, polymorphic: true
  belongs_to :harvest_source, inverse_of: :harvest_attempts
  belongs_to :harvest_set, inverse_of: :harvest_attempts, optional: true
  belongs_to :harvest_mapping, inverse_of: :harvest_attempts, optional: true

  has_one :harvest_configuration, inverse_of: :harvest_attempt, dependent: :nullify

  has_one_readonly :latest_harvest_attempt_link, inverse_of: :harvest_attempt

  has_many :harvest_attempt_record_links, inverse_of: :harvest_attempt, dependent: :delete_all

  has_one_readonly :harvest_attempt_record_status, inverse_of: :harvest_attempt

  has_many :harvest_attempt_entity_links, inverse_of: :harvest_attempt, dependent: :delete_all

  has_one_readonly :harvest_attempt_entity_status, inverse_of: :harvest_attempt

  has_many :harvest_messages, inverse_of: :harvest_attempt, dependent: :nullify

  has_many :harvest_records, through: :harvest_attempt_record_links

  has_many :harvest_entities, through: :harvest_records

  scope :current, -> { where(id: LatestHarvestAttemptLink.select(:harvest_attempt_id)) }
  scope :previous, -> { where.not(id: LatestHarvestAttemptLink.select(:harvest_attempt_id)) }

  scope :fully_scheduled, -> { in_state(:scheduled).scheduled }
  scope :scheduled_after, ->(now = Time.current) { fully_scheduled.where(scheduled_at: now..) }
  scope :scheduled_in_the_future, -> { scheduled_after(Time.current) }

  scope :in_default_order, -> { in_recent_order }
  scope :in_inverse_order, -> { in_oldest_order }

  attribute :metadata, Harvesting::Attempts::Metadata.to_type, default: proc { {} }

  alias_attribute :note, :description

  delegate :max_record_count, to: :metadata

  before_validation :inherit_metadata_format!

  def cancelled?
    in_state?(:cancelled)
  end

  monadic_operation! def connect_entity(...)
    call_operation("harvesting.attempts.entity_links.connect", self, ...)
  end

  monadic_operation! def connect_record(...)
    call_operation("harvesting.attempts.record_links.connect", self, ...)
  end

  # @see Harvesting::Attempts::ExtractRecords
  monadic_operation! def extract_records(...)
    call_operation("harvesting.attempts.extract_records", self, ...)
  end

  # @!group Harvesting Options

  # @api private
  # @return [HasHarvestingOptions]
  def harvest_parent
    harvest_mapping || harvest_source
  end

  delegate :list_options, :read_options, :format_options, :mapping_options, to: :harvest_parent

  monadic_operation! def prune_entities(...)
    call_operation("harvesting.attempts.prune_entities", self, ...)
  end

  private

  # @return [void]
  def inherit_metadata_format!
    self.metadata_format ||= harvest_parent.try(:metadata_format)
  end

  class << self
    # Fetch the current attempts for a given {HarvestSource}.
    #
    # A source can have multiple current attempts, based on whether or not the
    # attempt(s) are also associated with {HarvestMapping}s or {HarvestSet}s.
    #
    # @see .latest_for_source
    # @param [String, HarvestSource] sourcelike
    # @return [ActiveRecord::Relation<HarvestAttempt>]
    def current_for_source(sourcelike)
      for_source(sourcelike).current
    end

    # @return [ActiveRecord::Relation<HarvestAttempt>]
    def to_enqueue_for_next_hour(now: Time.current)
      base = now.at_beginning_of_hour

      start = base + 50.minutes
      close = base + 2.hours

      scheduled_at = start...close

      fully_scheduled.where(scheduled_at:)
    end
  end
end

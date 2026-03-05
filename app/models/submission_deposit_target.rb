# frozen_string_literal: true

# The actual target entity of a {SubmissionTarget}.
class SubmissionDepositTarget < ApplicationRecord
  include AssignsPolymorphicForeignKey
  include HasEphemeralSystemSlug
  include TimestampScopes

  pg_enum! :deposit_mode, as: :submission_deposit_mode, allow_blank: false, default: "direct", suffix: :deposit

  belongs_to :submission_target, inverse_of: :submission_deposit_targets, counter_cache: :deposit_targets_count, touch: true
  belongs_to :entity, polymorphic: true, inverse_of: :submission_deposit_targets
  belongs_to :schema_version, inverse_of: :submission_deposit_targets

  belongs_to :community, optional: true
  belongs_to :collection, optional: true
  belongs_to :item, optional: true

  delegate :entity, to: :submission_target, prefix: :target, allow_nil: true

  before_validation :determine_mode!

  before_validation :infer_schema_version!

  assign_polymorphic_foreign_key! :entity, :community, :collection, :item

  validates :entity_id, uniqueness: { scope: %i[entity_type submission_target_id] }

  validate :entity_must_be_self_or_descendant!

  private

  # @return [void]
  def determine_mode!
    self.deposit_mode = target_entity == entity ? :direct : :descendant
  end

  # @return [void]
  def entity_must_be_self_or_descendant!
    errors.add :base, "Deposit target entity must be the same as or a descendant of the submission target's entity" unless entity.self_or_descendant_of?(target_entity)
  end

  # @return [void]
  def infer_schema_version!
    self.schema_version = submission_target.schema_version
  end
end

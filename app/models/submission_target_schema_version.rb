# frozen_string_literal: true

# A connection between a {SubmissionTarget} and a {SchemaVersion}, indicating that the schema version is valid for submissions to the target.
class SubmissionTargetSchemaVersion < ApplicationRecord
  include HasEphemeralSystemSlug
  include TimestampScopes

  belongs_to :submission_target, inverse_of: :submission_target_schema_versions, counter_cache: :schema_versions_count
  belongs_to :schema_version, inverse_of: :submission_target_schema_versions

  scope :in_default_order, -> { joins(:schema_version).merge(SchemaVersion.in_default_order) }

  validates :submission_target_id, uniqueness: { scope: :schema_version_id }

  validate :must_be_child_schema!

  private

  # @return [void]
  def must_be_child_schema!
    errors.add :base, "Community schemas cannot be deposited" if schema_version.community?
  end
end

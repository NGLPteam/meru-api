# frozen_string_literal: true

# An enforced association for a {SchemaVersion}.
#
# The presence of a `target` schema means it can serve as the `name` for the `source` schema.
#
# If a schema has no records in this table for a given `name`, then _any_ schema can fill that
# role, assuming said schema also supports the child.
class SchemaVersionAssociation < ApplicationRecord
  include GenericAccessible
  include TimestampScopes

  belongs_to :source, class_name: "SchemaVersion"
  belongs_to :target, class_name: "SchemaVersion"

  scope :by_name, ->(name) { where(name:) }
  scope :by_source, ->(source) { where(source:) }
  scope :by_target, ->(target) { where(target:) }

  validates :name, presence: true, uniqueness: { scope: %i[source_id target_id] }
end

# frozen_string_literal: true

# This join model connects a {SchemaVersion} with one or more others, grouped by `name`,
# in order to represent valid schemas in an {HierarchicalEntity entity's} ancestry tree.
#
# For instance, `nglp:journal_article` defines 3 ancestor associations: `issue`, `volume`,
# and `journal` which are all within the `nglp` namespace. This model connects
# `journal_article` with each possible version of those so that entities can very easily
# determine which ancestor in their hierarchy conforms to each schema.
class SchemaVersionAncestor < ApplicationRecord
  include GenericAccessible
  include TimestampScopes

  belongs_to :schema_version, inverse_of: :schema_version_ancestors
  belongs_to :target_version, class_name: "SchemaVersion"

  has_one :schema_definition, through: :schema_version
  has_one :target_schema_definition, through: :target_version, source: :schema_definition

  scope :by_source, ->(source) { where(schema_version: source) }
  scope :by_target, ->(target) { where(target_version: target) }
  scope :by_name, ->(name) { where(name:) }
  scope :sans_target, ->(target) { where.not(target_version: target) }

  validates :name, presence: true, uniqueness: { scope: %i[schema_version_id target_version_id] }
end

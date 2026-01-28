# frozen_string_literal: true

# A view that provides derived ancestor information for {EntityAncestor}.
class EntityDerivedAncestor < ApplicationRecord
  include View

  self.primary_key = %i[entity_type entity_id name].freeze

  belongs_to_readonly :entity, polymorphic: true, inverse_of: :entity_derived_ancestors

  belongs_to_readonly :ancestor, polymorphic: true

  belongs_to_readonly :ancestor_schema_version, class_name: "SchemaVersion", foreign_key: :ancestor_schema_version_id, inverse_of: :entity_derived_ancestors

  scope :by_name, ->(name) { where(name:) }
  scope :in_default_order, -> { order(relative_depth: :asc, name: :asc) }
end

# frozen_string_literal: true

# A named, derived ancestor for a specific {Entity}, based on the defined
# ancestors in its {SchemaVersion}.
#
# It gets populated and updated automatically when an entity is created or
# reparented. The data comes from {EntityDerivedAncestor}.
#
# @see SchemaVersionAncestor
class EntityAncestor < ApplicationRecord
  include HasEphemeralSystemSlug
  include TimestampScopes

  belongs_to :entity, polymorphic: true, inverse_of: :named_ancestors

  belongs_to :ancestor, polymorphic: true, inverse_of: :named_descendants

  belongs_to :ancestor_schema_version, class_name: "SchemaVersion", inverse_of: :entity_ancestors

  scope :by_name, ->(name) { where(name:) }
  scope :in_default_order, -> { order(relative_depth: :asc, name: :asc) }

  class << self
    # @see Types::NamedAncestorType
    def graphql_node_type
      Types::NamedAncestorType
    end
  end
end

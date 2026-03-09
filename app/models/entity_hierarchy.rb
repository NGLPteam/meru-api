# frozen_string_literal: true

# Similar to {Entity}, this is designed to describe an entity hierarchy.
#
# It works similar to the closure tree `*_hierarchies` tables, but with
# added metadata to support our polymorphic tree.
class EntityHierarchy < ApplicationRecord
  include GenericInaccessible
  include TimestampScopes

  self.primary_key = %i[ancestor_id descendant_id]

  belongs_to :ancestor, polymorphic: true
  belongs_to :descendant, polymorphic: true
  belongs_to :hierarchical, polymorphic: true
  belongs_to :schema_definition
  belongs_to :schema_version
end

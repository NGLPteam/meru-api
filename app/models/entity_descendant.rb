# frozen_string_literal: true

# A view that calculates all descendants for a specific {HierarchicalEntity entity}.
#
# It is independent of type and includes links, allowing a greater deal of flexibility
# in being able to look through an entity's entire hierarchy.
class EntityDescendant < ApplicationRecord
  ENTITY_ADJACENT_PRIMARY_KEY = %i[descendant_type descendant_id].freeze

  include EntityAdjacent
  include GenericAccessible
  include FiltersByEntityScope
  include FiltersBySchemaVersion
  include TimestampScopes
  include View

  self.primary_key = %i[parent_type parent_id auth_path].freeze

  ValidDepth = Dry::Types["coercible.integer"].constrained(gt: 0)

  # The inverse
  # @return [HierarchicalEntity]
  belongs_to :parent, polymorphic: true, inverse_of: :entity_descendants

  # @return [HierarchicalEntity]
  belongs_to :descendant, polymorphic: true

  belongs_to :schema_version, inverse_of: :entity_descendants

  scope :by_max_depth, ->(value) { build_max_depth_scope_for(value) }
  scope :collections, -> { filtered_by_scope :collection }
  scope :sans_links, -> { where(link_operator: nil) }
  scope :unharvested, -> { where.not(descendant_id: HarvestEntity.existing_entity_ids) }

  class << self
    def build_max_depth_scope_for(value)
      case value
      when ValidDepth
        where arel_table[:relative_depth].lteq(value)
      end
    end

    # @return [ActiveRecord::Relation]
    def for_collection_filter
      collections.select(:descendant_id)
    end
  end
end

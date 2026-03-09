# frozen_string_literal: true

# A view that checks a given {HierarchicalEntity} against its {SchemaVersion}
# to see which orderings it should inherit, and then checks to see if:
#
# 1. an {Ordering} exists
# 2. whether it has been modified
# 3. whether the schema version for the ordering matches the entity
class EntityInheritedOrdering < ApplicationRecord
  include GenericAccessible
  include ScopesForIdentifier
  include View

  self.primary_key = %i[entity_id entity_type identifier]

  belongs_to :entity, polymorphic: true

  enum :status, %i[pristine missing mismatched modified].index_with(&:to_s)
end

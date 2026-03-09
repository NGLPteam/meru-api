# frozen_string_literal: true

module Audits
  # An audited view where the schema version in {Entity} does not
  # correspond to the actual {HierarchicalEntity}.
  class MismatchedEntitySchema < ApplicationRecord
    include GenericInaccessible
    include View

    self.primary_key = :synced_entity_id

    belongs_to_readonly :synced_entity, class_name: "Entity"
    belongs_to_readonly :source, polymorphic: true
    belongs_to_readonly :hierarchical, polymorphic: true
  end
end

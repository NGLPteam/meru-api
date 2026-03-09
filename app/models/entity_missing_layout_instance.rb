# frozen_string_literal: true

class EntityMissingLayoutInstance < ApplicationRecord
  include GenericAccessible
  include View

  self.primary_key = %i[entity_id layout_definition_id]

  belongs_to :entity, polymorphic: true, inverse_of: :missing_layout_instances

  belongs_to :layout_definition, polymorphic: true, inverse_of: :entity_missing_layout_instances
end

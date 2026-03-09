# frozen_string_literal: true

class EntityMissingTemplateInstance < ApplicationRecord
  include GenericAccessible
  include View

  self.primary_key = %i[entity_id layout_definition_id template_definition_id]

  belongs_to :entity, polymorphic: true, inverse_of: :missing_template_instances

  belongs_to :layout_definition, polymorphic: true, inverse_of: :entity_missing_template_instances

  belongs_to :template_definition, polymorphic: true, inverse_of: :entity_missing_template_instances
end

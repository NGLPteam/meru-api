# frozen_string_literal: true

class LayoutDefinitionHierarchy < ApplicationRecord
  include GenericAccessible
  include HasEphemeralSystemSlug
  include TimestampScopes

  belongs_to :schema_version, inverse_of: :layout_definition_hierarchies

  belongs_to :entity, polymorphic: true, optional: true, inverse_of: :layout_definition_hierarchies

  belongs_to :layout_definition, polymorphic: true, inverse_of: :layout_definition_hierarchy
end

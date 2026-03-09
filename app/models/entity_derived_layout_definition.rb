# frozen_string_literal: true

class EntityDerivedLayoutDefinition < ApplicationRecord
  include GenericAccessible
  include HasEphemeralSystemSlug
  include TimestampScopes

  belongs_to :entity, polymorphic: true, inverse_of: :entity_derived_layout_definitions

  belongs_to :layout_definition, polymorphic: true, inverse_of: :entity_derived_layout_definitions

  belongs_to :schema_version, inverse_of: :entity_derived_layout_definitions
end

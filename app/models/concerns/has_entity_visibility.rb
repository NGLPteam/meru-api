# frozen_string_literal: true

# For models that actually write to {EntityVisibility}, i.e. {Collection}, {Item}.
#
# @see ReferencesEntityVisibility
module HasEntityVisibility
  extend ActiveSupport::Concern
  extend DelegatesAssociationWriter

  include HierarchicalEntity
  include ReferencesEntityVisibility

  included do
    has_one :entity_visibility, as: :entity, dependent: :destroy, autosave: true, inverse_of: :entity
  end

  writes_association_attribute! :entity_visibility,  :hidden_at
  writes_association_attribute! :entity_visibility,  :visibility
  writes_association_attribute! :entity_visibility,  :visible_after_at
  writes_association_attribute! :entity_visibility,  :visible_until_at
end

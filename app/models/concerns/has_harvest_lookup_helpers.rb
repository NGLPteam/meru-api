# frozen_string_literal: true

# Helper methods for looking up children and similar scopes.
module HasHarvestLookupHelpers
  extend ActiveSupport::Concern

  # @param [HarvestEntity] harvest_entity
  # @return [Collection, Item]
  def find_or_initialize_harvested_child_for(harvest_entity)
    if harvest_entity.entity.present?
      existing_entity = harvest_entity.entity

      existing_entity.identifier = harvest_entity.identifier

      existing_entity
    else
      scope = harvest_child_scope_for harvest_entity

      scope.by_identifier(harvest_entity.identifier).first_or_initialize
    end.tap do |child|
      child.found_by_harvesting_action!
    end
  end

  # @param [Symbol] child_entity_kind
  # @return [ActiveRecord::Relation<Collection>]
  # @return [ActiveRecord::Relation<Item>]
  def child_scope_for(child_entity_kind)
    parent_type = entity_kind.to_sym
    child_type = child_entity_kind.to_sym

    case [parent_type, child_type]
    when [:community, :collection]
      collections
    when [:collection, :item]
      items
    when [:collection, :collection], [:item, :item]
      children
    else
      # :nocov:
      raise Harvesting::Error, "cannot create child of type #{child_type} under #{parent_type}"
      # :nocov:
    end
  end

  # @param [HarvestEntity] harvest_entity
  # @return [ActiveRecord::Relation<Collection>]
  # @return [ActiveRecord::Relation<Item>]
  def harvest_child_scope_for(harvest_entity)
    child_scope_for(harvest_entity.entity_kind)
  end
end

# frozen_string_literal: true

module Sources
  class AncestorOfType < GraphQL::Dataloader::Source
    # @param [String] schema
    def initialize(schema)
      @schema = schema
    end

    # @param [Array<HierarchicalEntity>] entities
    # @return [Array<HierarchicalEntity, nil>]
    def fetch(entities)
      ancestors = {}

      EntityBreadcrumb.for_ancestor_of_type(@schema, *entities).each do |breadcrumb|
        ancestors[breadcrumb.entity_id] = breadcrumb.crumb
      end

      entities.map do |entity|
        ancestors[entity.id] || nil
      end
    end
  end
end

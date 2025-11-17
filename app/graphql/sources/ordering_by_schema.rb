# frozen_string_literal: true

module Sources
  class OrderingBySchema < GraphQL::Dataloader::Source
    def initialize(slug)
      @slug = slug
    end

    # @param [<HierarchicalEntity>] entities
    def fetch(entities)
      hsh = {}

      Ordering.by_entity(entities).by_handled_schema_definition(@slug).find_each do |ordering|
        hsh[ordering.entity] = ordering
      end

      entities.map { |entity| hsh[entity] }
    end
  end
end

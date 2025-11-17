# frozen_string_literal: true

module Sources
  class OrderingByIdentifier < GraphQL::Dataloader::Source
    def initialize(identifier)
      @identifier = identifier
    end

    # @param [<HierarchicalEntity>] entities
    def fetch(entities)
      hsh = {}

      Ordering.by_entity(entities).by_identifier(@identifier).find_each do |ordering|
        hsh[ordering.entity] = ordering
      end

      entities.map { |entity| hsh[entity] }
    end
  end
end

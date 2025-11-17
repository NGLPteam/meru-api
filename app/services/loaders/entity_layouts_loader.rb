# frozen_string_literal: true

module Loaders
  class EntityLayoutsLoader < GraphQL::Batch::Loader
    # @param [<HierarchicalEntity>] entities
    # @return [void]
    def perform(entities)
      entities.each do |entity|
        layouts = entity.check_layouts.value_or(nil)

        fulfill(entity, layouts)
      end
    end

    # @param [HierarchicalEntity] record
    def cache_key(record)
      case record
      when ::HierarchicalEntity then record.id
      else
        # :nocov:
        raise TypeError, "#{record.inspect} cannot load entity layouts"
        # :nocov:
      end
    end
  end
end

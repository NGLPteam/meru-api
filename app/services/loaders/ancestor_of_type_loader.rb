# frozen_string_literal: true

module Loaders
  # An ability to calculate the _currently_ visible entries for multiple
  # {Ordering} instances at query time.
  class AncestorOfTypeLoader < GraphQL::Batch::Loader
    # @param [String] schema
    def initialize(schema)
      @schema = schema
    end

    # @param [<HierarchicalEntity>] entities
    def perform(entities)
      EntityBreadcrumb.for_ancestor_of_type(@schema, *entities).each do |breadcrumb|
        fulfill(breadcrumb, breadcrumb.crumb)
      end

      # simplecov:disable
      entities.each do |ent|
        fulfill(ent, nil) unless fulfilled?(ent)
      end
      # simplecov:enable
    end

    # @param [HierarchicalEntity, EntityBreadcrumb] record
    # @return [String]
    def cache_key(record)
      case record
      when EntityBreadcrumb
        record.entity_id
      else
        record.id
      end
    end
  end
end

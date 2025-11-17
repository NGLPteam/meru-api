# frozen_string_literal: true

module Types
  class BaseObject < Types::AbstractObjectType
    edge_type_class Types::BaseEdge

    connection_type_class Types::BaseConnection

    field_class Types::BaseField

    def call_operation(name, ...)
      MeruAPI::Container[name].call(...)
    end

    def call_operation!(name, ...)
      call_operation(name, ...).value!
    end

    # @api private
    # @param [HierarchicalEntity, nil] promise
    # @return [void]
    def track_entity_event!(promise, name: "entity.view", **data)
      promise.then do |entity|
        break if entity.blank? || context[:ahoy].blank?

        data[:entity] = entity

        context[:ahoy].track name, data
      end
    end

    # @api private
    # @param [String] name
    # @return [Analytics::EventCountSummary]
    def resolve_analytics_event_counts(name, **options)
      options[:name] = name

      ::Analytics::EventResolver.new(**options).call
    end

    # @api private
    # @param [String] name
    # @return [Analytics::RegionCountSummary]
    def resolve_analytics_region_counts(name, **options)
      options[:name] = name

      ::Analytics::EventRegionResolver.new(**options).call
    end
  end
end

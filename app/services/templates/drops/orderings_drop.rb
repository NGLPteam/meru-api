# frozen_string_literal: true

module Templates
  module Drops
    # A drop representing a collection of {OrderingDrop}s for a given
    # {HierarchicalEntity}.
    #
    # It makes use of lazy loading and caching to avoid unnecessary database
    # queries, and will calculate a helpful error message if an unknown
    # ordering identifier is requested.
    #
    # @see Templates::Drops::OrderingDrop
    class OrderingsDrop < Templates::Drops::AbstractDrop
      # @param [HierarchicalEntity] entity
      def initialize(entity)
        @entity = entity

        @cache = Concurrent::Map.new
      end

      # @param [#to_s] name
      # @raise [Liquid::UndefinedDropMethod]
      # @return [Templates::Drops::OrderingDrop]
      def liquid_method_missing(name)
        fetch_ordering_drop(name)
      rescue Entities::UnknownProperty => e
        raise Liquid::UndefinedDropMethod, e.message
      end

      def to_s
        # :nocov:
        raise Liquid::ContextError, "Tried to render orderings in scalar context"
        # :nocov:
      end

      private

      # @param [#to_s] ordering_identifier
      # @see HierarchicalEntity#ordering!
      # @raise [Entities::UnknownOrdering]
      # @return [Templates::Drops::OrderingDrop]
      def fetch_ordering_drop(ordering_identifier)
        @cache.compute_if_absent(ordering_identifier) do
          ordering = @entity.ordering!(ordering_identifier)

          ordering.to_liquid
        end
      rescue ActiveRecord::RecordNotFound
        raise Entities::UnknownOrdering.new(ordering_identifier:, entity: @entity)
      end
    end
  end
end

# frozen_string_literal: true

module Resolvers
  # Used for fetching descendants of the same type of entity.
  module Subtreelike
    extend ActiveSupport::Concern

    include Resolvers::FiltersBySchemaName

    included do
      option :node_filter,
        type: ::Types::SubtreeNodeFilterType,
        description: "Describe the depth of entities to retrieve",
        default: "CHILDREN"
    end

    def apply_node_filter_with_children(scope)
      if object.kind_of?(scope.model)
        scope.where(parent: object)
      else
        scope.roots
      end
    end

    def apply_node_filter_with_descendants(scope)
      if scope.model == Item && object.kind_of?(Collection)
        scope.rewhere(collection_id: object.self_and_descendants.select(:id))
      else
        scope.all
      end
    end
  end
end

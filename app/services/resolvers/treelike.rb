# frozen_string_literal: true

module Resolvers
  module Treelike
    extend ActiveSupport::Concern

    include Resolvers::FiltersBySchemaName

    included do
      option :node_filter,
        type: ::Types::TreeNodeFilterType,
        description: "Select the classification of nodes to retrieve: see TreeNodeFilter for a more thorough explanation",
        default: "ROOTS_ONLY"
    end

    def apply_node_filter_with_roots_only(scope)
      scope.roots
    end

    def apply_node_filter_with_roots_and_leaves(scope)
      scope.all
    end

    def apply_node_filter_with_leaves_only(scope)
      scope.leaves
    end
  end
end

# frozen_string_literal: true

module Resolvers
  module FiltersByAccessGrantEntity
    extend ActiveSupport::Concern

    included do
      option :entity, type: ::Types::AccessGrantEntityFilterType, default: "ALL"
    end

    def apply_entity_with_all(scope)
      scope.all
    end

    def apply_entity_with_community(scope)
      scope.for_communities
    end

    def apply_entity_with_collection(scope)
      scope.for_collections
    end

    def apply_entity_with_items(scope)
      scope.for_items
    end
  end
end

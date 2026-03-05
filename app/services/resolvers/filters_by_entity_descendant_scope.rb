# frozen_string_literal: true

module Resolvers
  # This module exposes an option on a resolver for an {EntityDescendant} that
  # allows it to filter by specific type(s), based on the `scope`.
  #
  # @see ::Types::EntityDescendantScopeFilterType
  module FiltersByEntityDescendantScope
    extend ActiveSupport::Concern

    included do
      option :scope, type: ::Types::EntityDescendantScopeFilterType, default: "ALL"
    end

    def apply_scope_with_all(scope)
      scope.all
    end

    def apply_scope_with_any_entity(scope)
      scope.filtered_by_scope(:any_entity)
    end

    def apply_scope_with_any_link(scope)
      scope.filtered_by_scope(:any_link)
    end

    def apply_scope_with_collection(scope)
      scope.filtered_by_scope(:collection)
    end

    def apply_scope_with_collection_or_link(scope)
      scope.filtered_by_scope(:collection_or_link)
    end

    def apply_scope_with_item(scope)
      scope.filtered_by_scope :item
    end

    def apply_scope_with_item_or_link(scope)
      scope.filtered_by_scope :item_or_link
    end

    def apply_scope_with_linked_collection(scope)
      scope.filtered_by_scope :linked_collection
    end

    def apply_scope_with_linked_item(scope)
      scope.filtered_by_scope :linked_item
    end
  end
end

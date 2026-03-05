# frozen_string_literal: true

module Resolvers
  # Methods for ordering a connection of {EntityDescendant}.
  #
  # @see ::Types::EntityDescendantOrderType
  module OrderedAsEntityDescendant
    extend ActiveSupport::Concern

    included do
      option :order, type: ::Types::EntityDescendantOrderType, default: "PUBLISHED_DESCENDING", required: true
    end

    def apply_order_with_published_ascending(scope)
      scope.with_sorted_published_date(:asc)
    end

    def apply_order_with_published_descending(scope)
      scope.with_sorted_published_date(:desc)
    end

    def apply_order_with_title_ascending(scope)
      scope.order(title: :asc)
    end

    def apply_order_with_title_descending(scope)
      scope.order(title: :desc)
    end
  end
end

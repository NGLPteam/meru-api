# frozen_string_literal: true

module Resolvers
  class SchemaVersionResolver < AbstractResolver
    include Resolvers::Enhancements::PageBasedPagination

    type ::Types::SchemaVersionType.connection_type, null: false

    resolves_model! ::SchemaVersion

    option :namespace, type: String do |scope, value|
      scope.by_namespace(value) if value.present?
    end

    option :order, type: ::Types::SchemaVersionOrderType, default: "LATEST"

    def apply_order_with_latest(scope)
      scope.order(number: :desc)
    end

    def apply_order_with_oldest(scope)
      scope.order(number: :asc)
    end
  end
end

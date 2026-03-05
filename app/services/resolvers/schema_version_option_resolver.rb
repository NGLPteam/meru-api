# frozen_string_literal: true

module Resolvers
  class SchemaVersionOptionResolver < AbstractResolver
    include Resolvers::BySchemaKind

    type [::Types::SchemaVersionOptionType, { null: false }], null: false

    resolves_model! ::SchemaVersion, from_object: false

    option :namespace, type: String do |scope, value|
      scope.by_namespace(value) if value.present?
    end

    def resolve_default_scope
      super.in_default_order.preload(:schema_definition)
    end

    def apply_order_with_latest(scope)
      scope.order(number: :desc)
    end

    def apply_order_with_oldest(scope)
      scope.order(number: :asc)
    end
  end
end

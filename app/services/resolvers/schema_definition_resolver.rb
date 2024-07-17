# frozen_string_literal: true

module Resolvers
  class SchemaDefinitionResolver < AbstractResolver
    include Resolvers::Enhancements::PageBasedPagination
    include Resolvers::SimplyOrdered

    type Types::SchemaDefinitionType.connection_type, null: false

    scope { SchemaDefinition.all }

    option :namespace, type: String do |scope, value|
      scope.by_namespace(value) if value.present?
    end
  end
end

# frozen_string_literal: true

module Resolvers
  module FiltersBySchemaName
    extend ActiveSupport::Concern

    included do
      option :schema, type: [String, { null: false }], description: "Filter by a namespace.name schema identifier" do |scope, value|
        value.present? ? scope.filtered_by_schema_version(value) : scope.all
      end
    end
  end
end

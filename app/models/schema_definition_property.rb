# frozen_string_literal: true

# A materialized view composed of properties from {SchemaVersionProperty},
# aggregated by their shared {SchemaDefinition}.
#
# It is used to describe the available schema properties for ordering and other purposes in the system.
class SchemaDefinitionProperty < ApplicationRecord
  include FiltersBySchemaDefinition
  include GenericAccessible
  include WrapsSchemaProperty
  include MaterializedView
  include TimestampScopes

  self.primary_key = %i[schema_definition_id path type]

  belongs_to :schema_definition, inverse_of: :schema_definition_properties

  class << self
    def fetch(schema_definition, path)
      definition = SchemaDefinition[schema_definition]

      by_schema_definition(definition).by_path(path).first!
    end

    # @return [ActiveRecord::Relation<SchemaDefinitionProperty>]
    def filtered_by_schema_version(*schemas)
      schemas.flatten!

      return all if schemas.blank?

      schema_versions = Array(schemas).map do |needle|
        MeruAPI::Container["schemas.versions.find"].call(needle).value_or(nil)
      end.compact

      return none if schema_versions.blank?

      id_matches = schema_versions.map do |sv|
        %[@ .id == #{sv.id.inspect}]
      end.join(" || ")

      path = arel_quote "exists($[*] ? (#{id_matches}))"

      path_match = arel_infix "@@", arel_table[:versions], path

      where path_match
    end
  end
end

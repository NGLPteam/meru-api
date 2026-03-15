# frozen_string_literal: true

module Types
  # @see SchemaDefinition
  class SchemaDefinitionType < Types::AbstractModel
    disable_auth_checks!

    description <<~TEXT
    A schema definition is a logical grouping of `SchemaVersion`s that identifies
    only the shared kind, namespace, and identifier. The name is also most likely
    shared, although it can change between schema versions, and the value on the
    definition will default to whatever the most recent version uses.
    TEXT

    implements Types::DescribesSchemaType

    def slug
      object.declaration
    end
  end
end

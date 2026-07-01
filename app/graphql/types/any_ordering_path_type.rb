# frozen_string_literal: true

module Types
  # @see Types::SchemaPropertyOrderingPathType
  # @see Types::StaticOrderingPathType
  class AnyOrderingPathType < Types::BaseUnion
    possible_types Types::SchemaOrderingPathType, Types::StaticOrderingPathType,
      Types::AncestorSchemaOrderingPathType, Types::AncestorStaticOrderingPathType

    description <<~TEXT
    All types in this union implement OrderingPath.
    TEXT

    class << self
      def resolve_type(object, context)
        case object
        when ::Schemas::Orderings::PathOptions::StaticReader
          Types::StaticOrderingPathType
        when ::Schemas::Orderings::PathOptions::SchemaReader
          Types::SchemaOrderingPathType
        when ::Schemas::Orderings::PathOptions::AncestorSchemaReader
          Types::AncestorSchemaOrderingPathType
        when ::Schemas::Orderings::PathOptions::AncestorStaticReader
          Types::AncestorStaticOrderingPathType
        else
          # simplecov:disable
          raise GraphQL::ExecutionError, "Unknown ordering path: #{object.inspect}"
          # simplecov:enable
        end
      end
    end
  end
end

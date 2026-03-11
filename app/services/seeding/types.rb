# frozen_string_literal: true

module Seeding
  # Types for handling seeding entities.
  module Types
    extend ::Support::Typespace

    Entity = Instance(::Community) | Instance(::Collection) | Instance(::Item)

    EntityClass = Inherits(::HierarchicalEntity)

    # A pattern for matching a fully-qualified schema definition.
    #
    # @note This pattern supports only `namespace:identifier` usage.
    #
    # @see Schemas::Types::DeclarationPattern
    SCHEMA_DECLARATION_PATTERN = /\A(?<namespace>[a-z_]+):(?<identifier>[a-z_0-9]+)\z/

    # The `namespace` portion of {SCHEMA_DECLARATION_PATTERN}
    SCHEMA_NAMESPACE_PATTERN = /\A[a-z_]+\z/

    # The `identifier` portion of {SCHEMA_DECLARATION_PATTERN}.
    SCHEMA_IDENTIFIER_PATTERN = /\A[a-z_0-9]+\z/

    CoercibleStringList = Coercible::Array.of(Coercible::String)

    CommunitySchema = String.default("default:community").enum("default:community")

    CollectionSchema = String.default("default:collection").enum("default:collection", "nglp:journal", "nglp:series", "nglp:unit")

    DefaultFalse = Params::Bool.default(false).fallback(false)

    IdentifierList = Array.of(String)

    IdentifierPath = Coercible::Array.of(Coercible::String).default { [] }

    IdentifierPaths = Coercible::Array.of(IdentifierPath).default { [] }

    ImportVersion = Instance(Semantic::Version) | Constructor(Semantic::Version)

    SchemaDeclaration = String.constrained(format: SCHEMA_DECLARATION_PATTERN)

    SchemaNamespace = String.constructor do |value|
      case value
      when SCHEMA_DECLARATION_PATTERN
        Regexp.last_match[:namespace]
      else
        value
      end
    end.constrained(format: SCHEMA_NAMESPACE_PATTERN)

    SchemaIdentifier = String.constructor do |value|
      case value
      when SCHEMA_DECLARATION_PATTERN
        Regexp.last_match[:identifier]
      else
        value
      end
    end.constrained(format: SCHEMA_IDENTIFIER_PATTERN)
  end
end

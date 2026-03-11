# frozen_string_literal: true

module Schemas
  module Static
    module Types
      extend ::Support::Typespace

      Component = ::Schemas::Types::Component

      DefinitionDeclaration = Coercible::String.constrained(format: ::Schemas::Types::DECLARATION_PATTERN)

      Namespace = Coercible::String.default("nglp").enum(*::SchemaDefinition::BUILTIN_NAMESPACES)

      Pathname = Instance(::Pathname)

      SchemaKind = ApplicationRecord.dry_pg_enum(:schema_kind)

      SemanticVersion = ::Schemas::Types::SemanticVersion

      VersionDeclaration = Coercible::String.constrained(format: ::Schemas::Types::VERSION_DECLARATION_PATTERN)

      VersionNumber = Coercible::String.constrained(format: ::Schemas::Types::SEMVER_PATTERN)
    end
  end
end

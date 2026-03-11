# frozen_string_literal: true

module Harvesting
  module Frozen
    # Types for top-level harvesting frozen records..
    module Types
      extend ::Support::Typespace

      Identifier = Coercible::String.constrained(filled: true)

      ExtractionMapping = Instance(::Harvesting::Extraction::Mapping)

      SchemaDeclaration = ::Schemas::Types::Declaration

      SchemaDeclarations = Coercible::Array.of(SchemaDeclaration)

      SchemaVersion = ModelInstance("SchemaVersion")

      SchemaVersions = Coercible::Array.of(SchemaVersion)
    end
  end
end

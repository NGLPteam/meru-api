# frozen_string_literal: true

module Schemas
  module System
    module Types
      extend ::Support::Typespace

      # A logical grouping for the kind of property.
      #
      # There's an associated enum type in the database: `schema_property_kind`.
      KindName = ApplicationRecord.dry_pg_enum(:schema_property_kind)

      # A known schema property type name.
      TypeName = ApplicationRecord.dry_pg_enum(:schema_property_type, default: "unknown")
    end
  end
end

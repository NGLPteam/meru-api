# frozen_string_literal: true

module Harvesting
  module Extraction
    module Types
      extend ::Support::Typespace

      Assigns = Coercible::Hash.map(Coercible::String, Any)

      SchemaPropertyType = ApplicationRecord.dry_pg_enum(:schema_property_type, default: "unknown").fallback("unknown")

      StrippedString = String.constructor do |input|
        next "" if input.blank? || input == Dry::Types::Undefined

        input.to_s.strip
      end

      SymbolList = Coercible::Array.of(Coercible::Symbol)
    end
  end
end

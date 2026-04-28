# frozen_string_literal: true

module Assets
  module Types
    extend ::Support::Typespace

    AccessMode = Coercible::String.enum("download", "view").fallback("view")

    Kind = ApplicationRecord.dry_pg_enum(:asset_kind, default: "unknown").fallback("unknown")
  end
end

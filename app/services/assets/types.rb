# frozen_string_literal: true

module Assets
  module Types
    extend ::Support::Typespace

    Kind = ApplicationRecord.dry_pg_enum(:asset_kind, default: "unknown").fallback("unknown")
  end
end

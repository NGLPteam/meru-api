# frozen_string_literal: true

module JournalSources
  module Types
    extend ::Support::Typespace

    UNKNOWN = "UNKNOWN"

    KnowableString = String.default(UNKNOWN).fallback(UNKNOWN)

    Mode = Symbol.enum(:unknown, :full, :volume_only, :issue_only)

    LiquidMode = Coercible::String.enum(*Mode.values.map(&:to_s)).fallback("unknown")

    OptionalInteger = Coercible::Integer.optional.fallback(nil)

    OptionalString = String.optional.default(nil).fallback(nil)
  end
end

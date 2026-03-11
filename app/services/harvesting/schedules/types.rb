# frozen_string_literal: true

module Harvesting
  module Schedules
    module Types
      extend ::Support::Typespace

      include Support::EnhancedTypes

      FrequencyExpression = String.optional

      Mode = ApplicationRecord.dry_pg_enum(:harvest_schedule_mode, default: "manual").fallback("manual")

      OccurrencesCount = Integer.default(10).constrained(gt: 0, lteq: 20).fallback(10)
    end
  end
end

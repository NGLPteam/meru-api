# frozen_string_literal: true

module Analytics
  # @see Types::AnalyticsRegionCountSummaryType
  class RegionCountSummary < ::Support::FlexibleStruct
    attribute :results, Analytics::Types::Array.of(Analytics::RegionCountResult)

    attribute :unfiltered_total, Analytics::Types::Integer

    attribute :total, Analytics::Types::Integer
  end
end

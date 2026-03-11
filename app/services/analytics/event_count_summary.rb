# frozen_string_literal: true

module Analytics
  # @see Types::AnalyticsEventCountSummaryType
  class EventCountSummary < ::Support::FlexibleStruct
    attribute :min_date, Analytics::Types::Date.optional

    attribute :max_date, Analytics::Types::Date.optional

    attribute :precision, Analytics::Types::Precision

    attribute :results, Analytics::Types::Array.of(Analytics::EventCountResult)

    attribute :unfiltered_total, Analytics::Types::Integer

    attribute :total, Analytics::Types::Integer
  end
end

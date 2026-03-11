# frozen_string_literal: true

module Analytics
  # @see Types::AnalyticsRegionCountResultType
  class RegionCountResult < ::Support::FlexibleStruct
    attribute? :country_code, Analytics::Types::String.default("$unknown$")
    attribute? :region_code, Analytics::Types::String.default("$unknown$")
    attribute? :count, Analytics::Types::Integer.default(0)
  end
end

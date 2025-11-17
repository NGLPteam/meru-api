# frozen_string_literal: true

module Types
  module AssetType
    include Types::BaseInterface

    implements ::GraphQL::Types::Relay::Node
    implements ::Types::SluggableType

    description "A generic asset type, implemented by all the more specific kinds"

    field :alt_text, String, null: true
    field :attachable, Types::AttachableType, null: false
    field :name, String, null: false
    field :caption, String, null: true
    field :kind, Types::AssetKindType, null: false
    field :file_size, Integer, null: false
    field :content_type, String, null: false
    field :downloadUrl, String, null: true, method: :download_url, deprecation_reason: "Use downloadURL instead"
    field :download_url, String, null: true

    image_attachment_field :preview

    field :asset_downloads, Types::AnalyticsEventCountSummaryType, null: false do
      extension Analytics::Extensions::FiltersByDate
      extension Analytics::Extensions::FiltersByPrecision
    end

    field :asset_downloads_by_region, Types::AnalyticsRegionCountSummaryType, null: false do
      extension Analytics::Extensions::FiltersByDate
      extension Analytics::Extensions::FiltersByUnitedStatesOnly
    end

    # @param [Hash] options
    # @return [Analytics::EventCountSummary]
    def asset_downloads(**options)
      options[:subjects] = [object]

      resolve_analytics_event_counts("asset.download", **options)
    end

    # @param [Hash] options
    # @return [Analytics::RegionCountSummary]
    def asset_downloads_by_region(**options)
      options[:subjects] = [object]

      resolve_analytics_region_counts("asset.download", **options)
    end
  end
end

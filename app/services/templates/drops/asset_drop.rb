# frozen_string_literal: true

module Templates
  module Drops
    # A drop that wraps around an {Asset}.
    class AssetDrop < Templates::Drops::AbstractDrop
      # @return [Integer]
      attr_reader :size

      # @return [String]
      attr_reader :url

      delegate :alt_text, :caption, :content_type, :name, :original_filename, to: :@asset

      alias filename original_filename

      # @param [Asset] asset
      def initialize(asset)
        super()

        @asset = asset

        @size = asset.file_size

        @url = asset.generate_download_url!(expires_at: 7.years.from_now)
      end

      def to_s
        # simplecov:disable
        call_operation!("templates.mdx.build_asset", asset: @asset, content: name)
        # simplecov:enable
      end
    end
  end
end

# frozen_string_literal: true

module Harvesting
  module Assets
    # @api private
    class EntityMapping
      include Support::EnhancedStoreModel

      IMAGES = %i[hero_image logo thumbnail].freeze

      IMAGE_URL_MAPPINGS = IMAGES.index_by do |img|
        :"#{img}_remote_url="
      end.freeze

      IMAGE_REMOTE_URLS = IMAGE_URL_MAPPINGS.keys.map(&:to_s).freeze

      attribute :hero_image, Harvesting::Assets::ExtractedSource.to_type, default: proc { { identifier: "hero_image" } }
      attribute :logo, Harvesting::Assets::ExtractedSource.to_type, default: proc { { identifier: "logo" } }
      attribute :thumbnail, Harvesting::Assets::ExtractedSource.to_type, default: proc { { identifier: "thumbnail" } }

      def blank?
        super || images.blank?
      end

      # @return [<Harvesting::Assets::ExtractedSource>]
      def images
        [hero_image, logo, thumbnail].compact_blank
      end

      # @api private
      #
      # @param [:hero_image, :logo, :thumbnail] identifier
      # @param [String] url
      # @param [String, nil] name
      # @param [String, nil] mime_type
      def assign_remote_url(identifier, url, name: nil, mime_type: nil)
        source = { identifier:, url:, name:, mime_type: }.compact_blank

        self[identifier] = source
      end

      IMAGES.each do |img|
        class_eval <<~RUBY, __FILE__, __LINE__ + 1
        def #{img}_remote_url=(url)
          assign_remote_url #{img.inspect}, url
        end
        RUBY
      end
    end
  end
end

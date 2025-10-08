# frozen_string_literal: true

module Harvesting
  module Entities
    # Attach an entity asset like a thumbnail, hero image, etc.
    class AttachEntityAsset
      include MonadicPersistence
      include Dry::Monads[:result, :do]
      include Harvesting::WithLogger
      include MeruAPI::Deps[
        fetch_cached_asset: "harvesting.cached_assets.fetch",
        add_reference: "harvesting.cached_assets.reference",
      ]

      # @param [Attachable] entity
      # @param [Harvesting::Assets::ExtractedSource] source
      # @return [Dry::Monads::Result]
      def call(entity, source)
        cached = yield fetch_cached_asset.(source.url) if source.present?

        found = yield maybe_attach! entity, source, cached

        entity.reload

        Success found ? source.identifier : nil
      end

      private

      # @param [Attachable] entity
      # @param [Harvesting::Assets::ExtractedSource] source
      # @return [Shrine::Attacher]
      def attacher_for(entity, source)
        attacher_method = :"#{source.identifier}_attacher"

        entity.public_send attacher_method
      end

      # @param [Attachable] entity
      # @param [Harvesting::Assets::ExtractedSource] source
      # @param [HarvestCachedAsset] cached
      # @return [Dry::Monads::Result]
      def maybe_attach!(entity, source, cached)
        attacher = attacher_for entity, source

        return Success(false) if cached.blank?

        return Success(true) if skip?(cached, attacher)

        if cached.has_asset?
          metadata = source.to_metadata

          cached.asset.download do |io|
            attacher.assign(io, metadata:)

            monadic_save(entity).or do |(_code, _model, errors)|
              attacher.assign nil

              logger.error(
                "Invalid entity asset: #{errors.to_sentence}",
                code: :invalid_entity_asset,
                errors:,
                content_type: cached.content_type,
                identifier: source.identifier,
                url: cached.url
              )

              Success(false)
            end
          end
        else
          if attacher.file.blank?
            logger.error("Cannot retrieve #{cached.url}", url: cached.url, code: :asset_not_found)
          end

          Success false
        end
      end

      def skip?(cached, attacher)
        return false if attacher.file.blank?

        existing_signature = attacher.file.metadata["sha256"]

        cached.signature == existing_signature
      end
    end
  end
end

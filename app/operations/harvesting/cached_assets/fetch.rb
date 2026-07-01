# frozen_string_literal: true

module Harvesting
  module CachedAssets
    # @see HarvestCachedAsset
    class Fetch
      include Dry::Monads[:result, :do]
      include MonadicPersistence

      NOT_FOUND = /remote file not found/

      # @return [Dry::Monads::Success(HarvestCachedAsset)]
      def call(url)
        HarvestCachedAsset.for_url url do |cached|
          yield maybe_upsert!(cached)

          cached.touch :touched_at

          Success cached
        end
      end

      private

      # @param [HarvestCachedAsset] cached
      # @return [Dry::Monads::Result]
      def maybe_fetch!(cached)
        return Success() if cached.has_asset?

        cached.asset_remote_url = cached.url
        cached.metadata.not_found = false

        yield monadic_save cached

        cached.touch :fetched_at

        Success()
      end

      # @param [HarvestCachedAsset] cached
      # @return [Dry::Monads::Result]
      def maybe_upsert!(cached)
        maybe_fetch!(cached).or do |reason|
          case reason
          in [:invalid, _, Array => errors] if errors.grep(NOT_FOUND).present?
            cached.asset = nil
            cached.metadata.not_found = true
            cached.fetched_at = Time.current

            yield monadic_save cached

            Success()
          else
            # simplecov:disable
            Failure[*reason]
            # simplecov:enable
          end
        end
      end
    end
  end
end

# frozen_string_literal: true

module Assets
  class GenerateDownloadURL
    include Dry::Monads[:do, :result]
    include MeruAPI::Deps[
      encode_download_token: "assets.encode_download_token",
      routes: "system.routes"
    ]

    # @param [Asset] asset
    # @param [Hash] options
    # @return [Dry::Monads::Success(String)]
    # @return [Dry::Monads::Success(nil)] if accidentally called on a non-persisted asset.
    def call(asset, **options)
      # simplecov:disable
      return Success(nil) unless asset.persisted?
      # simplecov:enable

      token = yield encode_download_token.(asset, **options)

      Success routes.download_url(asset.system_slug, token:)
    end
  end
end

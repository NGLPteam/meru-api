# frozen_string_literal: true

module Assets
  class DecodeDownloadToken
    include Dry::Monads[:do, :result]
    include MeruAPI::Deps[
      decode: "tokens.decode",
    ]

    # @param [Asset] asset
    # @param [String] token
    # @return [Dry::Monads::Success("download" | "view")]
    def call(asset, token)
      return Failure[:missing_token] if token.blank?

      payload = yield decode.(token, aud: "download", sub: asset.id, verify_expiration: false)

      mode = Assets::Types::AccessMode[payload["mode"]]

      Success mode
    end
  end
end

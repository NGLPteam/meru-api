# frozen_string_literal: true

module Assets
  class EncodeDownloadToken
    include Dry::Monads[:do, :result]
    include MeruAPI::Deps[
      encode: "tokens.encode",
    ]

    # @param [Asset] asset
    # @param ["download", "view"] mode
    # @return [Dry::Monads::Success(String)]
    def call(asset, mode: "download", expires_at: 2.weeks.from_now)
      payload = { aud: "download", sub: asset.id }

      payload[:mode] = Assets::Types::AccessMode[mode]
      payload[:exp] = expires_at.to_i

      encode.(payload)
    end
  end
end

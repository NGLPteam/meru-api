# frozen_string_literal: true

module Geocoding
  class Lookup
    include Dry::Monads[:do, :result]

    # @param [String] ip
    # @return [Dry::Monads::Success(Geocoding::Result)]
    # @return [Dry::Monads::Failure(:not_found)]
    # @return [Dry::Monads::Failure(:error, Exception)]
    def call(ip)
      location = yield search(ip)

      data = {
        country: location.country,
        country_code: location.try(:country_code).presence,
        region: location.try(:state).presence,
        region_code: location.try(:province_code).presence,
        city: location.try(:city).presence,
        postal_code: location.try(:postal_code).presence,
        latitude: location.try(:latitude).presence,
        longitude: location.try(:longitude).presence
      }.compact_blank

      Success Geocoding::Result.new(data)
    end

    private

    # @param [String] ip
    # @return [Dry::Monads::Result]
    def search(ip)
      location = Geocoder.search(ip).first
    rescue StandardError => e
      # simplecov:disable
      Failure[:error, e]
      # simplecov:enable
    else
      if location && location.country.present?
        Success location
      else
        Failure[:not_found]
      end
    end
  end
end

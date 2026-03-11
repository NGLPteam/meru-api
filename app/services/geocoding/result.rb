# frozen_string_literal: true

module Geocoding
  # @see Geocoding::Lookup
  class Result < ::Support::FlexibleStruct
    attribute :country, Geocoding::Types::String
    attribute? :country_code, Geocoding::Types::String.optional
    attribute? :region, Geocoding::Types::String.optional
    attribute? :region_code, Geocoding::Types::String.optional
    attribute? :city, Geocoding::Types::String.optional
    attribute? :postal_code, Geocoding::Types::String.optional
    attribute? :latitude, Geocoding::Types::Float.optional
    attribute? :longitude, Geocoding::Types::Float.optional
  end
end

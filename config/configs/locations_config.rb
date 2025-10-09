# frozen_string_literal: true

class LocationsConfig < ApplicationConfig
  INCLUDED_PORT = Dry::Types["integer"].constrained(excluded_from: [80, 443])

  attr_config :frontend_internal, :admin_internal, frontend: "http://localhost:14700", admin: "http://localhost:3000", api: "http://localhost:6222", debug: "http://localhost:3400"

  def admin_request
    admin_internal.presence || admin
  end

  def frontend_request
    frontend_internal.presence || frontend
  end

  # @return [Hash]
  memoize def api_url_options
    url_options_for api
  end

  # @return [String]
  def default_graphql_endpoint
    URI.join(api, "/graphql").to_s
  end

  private

  # @param [String] endpoint
  # @return [{ Symbol => Object }]
  def url_options_for(endpoint)
    url = URI(endpoint)

    {
      protocol: url.scheme,
      host: url.host,
      port: sanitize_port(url.port),
    }.compact
  end

  def sanitize_port(value)
    INCLUDED_PORT.try(value).to_monad.value_or(nil)
  end
end

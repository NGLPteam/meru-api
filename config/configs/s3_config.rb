# frozen_string_literal: true

class S3Config < ApplicationConfig
  attr_config :access_key_id, :secret_access_key, :endpoint, :region, force_path_style: false, stub_responses: false

  coerce_types force_path_style: :boolean, stub_responses: :boolean

  # @return [Aws::S3::Client]
  def build_s3_client
    build_client_for(endpoint, force_path_style:, stub_responses:)
  end

  # @param [String] endpoint
  # @param [Boolean] force_path_style
  # @param [Boolean] stub_responses
  # @return [Aws::S3::Client]
  def build_client_for(endpoint, force_path_style: false, stub_responses: false)
    Aws::S3::Client.new(
      access_key_id:,
      secret_access_key:,
      endpoint:,
      force_path_style:,
      stub_responses:,
      region:
    )
  end
end

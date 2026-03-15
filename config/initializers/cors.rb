# frozen_string_literal: true

# Be sure to restart your server when you modify this file.

module CORSHelper
  METHODS = %i[get post patch put delete options head].freeze
  S3MP_HEADERS = %w[Authorization Content-Type x-amz-content-sha256 x-amz-date Upload-Token].freeze
  S3MP_EXPOSED = %w[ETag].freeze
  TUS_EXPOSED = %w[
    Location
    Upload-Concat Upload-Defer-Length Upload-Length Upload-Metadata Upload-Offset
    Tus-Version Tus-Resumable Tus-Max-Size Tus-Extension
  ].freeze
end

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.
# Read more: https://github.com/cyu/rack-cors
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ?*

    resource "/s3/multipart/*", headers: CORSHelper::S3MP_HEADERS, methods: CORSHelper::METHODS,
      expose: CORSHelper::S3MP_EXPOSED

    resource "/files/*", headers: :any, methods: CORSHelper::METHODS,
      expose: CORSHelper::TUS_EXPOSED

    resource ?*, headers: :any, methods: CORSHelper::METHODS
  end
end

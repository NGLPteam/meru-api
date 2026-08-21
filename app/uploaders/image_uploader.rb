# frozen_string_literal: true

# An uploader specifically for images, with common dimensions and formats.
#
# @see ImageAttachments::ImageWrapper
class ImageUploader < Shrine
  plugin :add_metadata
  plugin :refresh_metadata
  plugin :remote_url, max_size: 100.megabytes, downloader: ::Support::Networking::SHRINE_REMOTE_URL_DOWNLOADER
  plugin :store_dimensions, analyzer: :ruby_vips
  plugin :signature
  plugin :validation_helpers
  plugin :restore_cached_data

  plugin :included do |name|
    include ImageAttachments::ModelIntegration[name]
  end

  metadata_method :alt

  add_metadata :generated_at do |io, **|
    Time.current.iso8601
  end

  add_metadata :sha256 do |io, derivative: nil, **|
    calculate_signature(io, :sha256, format: :base64) unless derivative
  end

  Attacher.validate do
    validate_mime_type %w[image/jpg image/jpeg image/png image/tiff image/webp image/heic image/heif image/gif image/svg+xml]
  end

  Attacher.derivatives do |original|
    MeruAPI::Container["image_attachments.generate_derivatives"].call(original).value!
  end

  UploadedFile.include ImageAttachments::HasMetadata
  UploadedFile.include ImageAttachments::ToLiquid
end

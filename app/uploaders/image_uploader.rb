# frozen_string_literal: true

# An uploader specifically for images, with common dimensions and formats.
#
# @see ImageAttachments::ImageWrapper
class ImageUploader < Shrine
  plugin :remote_url, max_size: 100.megabytes, downloader: ::Support::Networking::SHRINE_REMOTE_URL_DOWNLOADER
  plugin :store_dimensions, analyzer: :ruby_vips
  plugin :validation_helpers
  plugin :restore_cached_data

  plugin :included do |name|
    include ImageAttachments::ModelIntegration[name]
  end

  metadata_method :alt

  Attacher.validate do
    validate_mime_type %w[image/jpg image/jpeg image/png image/tiff image/webp image/heic image/heif image/gif image/svg+xml]
  end

  Attacher.derivatives do |original|
    MeruAPI::Container["image_attachments.generate_derivatives"].call(original).value!
  end

  UploadedFile.include ImageAttachments::HasMetadata
  UploadedFile.include ImageAttachments::ToLiquid
end

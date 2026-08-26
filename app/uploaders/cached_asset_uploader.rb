# frozen_string_literal: true

# An uploader for storing assets retrieved during harvesting and cached by their unique URL.
#
# Unlike other uploaders, it does _not_ background its asset promotion or destruction logic,
# as we want the stored asset available immediately, and it does not perform any sort of
# derivative generation or anything else that would warrant the delay.
#
# @see HarvestCachedAsset
class CachedAssetUploader < Shrine
  plugin :infer_extension, force: true
  plugin :remote_url, max_size: 5.gigabytes, downloader: ::Support::Networking::SHRINE_REMOTE_URL_DOWNLOADER
  plugin :validation_helpers
  plugin :restore_cached_data
  plugin :metadata_attributes, filename: "file_name", size: "file_size", mime_type: "content_type", sha256: "signature"

  add_metadata skip_nil: true do |io, metadata:, **|
    # Deal with invalid unicode encoding in filenames

    raw_filename = metadata["filename"].presence || "asset"

    filename = raw_filename.encode("UTF-8", invalid: :replace, undef: :replace, replace: ?-)

    fallback = ["asset", File.extname(filename)].join

    filename = Zaru.sanitize!(filename, fallback:)

    { filename:, }
  end

  Attacher.validate do
    validate_max_size 5.gigabytes
  end

  Attacher.promote_block { promote }
  Attacher.destroy_block { destroy }
end

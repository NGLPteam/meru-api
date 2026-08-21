# frozen_string_literal: true

# An uploader that allows effectively any type of file. Its primary application is with {Asset assets},
# allowing users to attach just about anything to an entity.
#
# It stores some metadata about the kind of asset it detects, see {Assets::ParseKind}.
class GenericUploader < Shrine
  plugin :add_metadata
  plugin :refresh_metadata
  plugin :infer_extension, force: true
  plugin :remote_url, max_size: 3.gigabytes, downloader: ::Support::Networking::SHRINE_REMOTE_URL_DOWNLOADER
  plugin :signature
  plugin :validation_helpers
  plugin :restore_cached_data
  plugin :metadata_attributes, kind: "kind", filename: "file_name", size: "file_size", mime_type: "content_type"

  add_metadata :generated_at do |io, **|
    Time.current.iso8601
  end

  add_metadata :sha256, skip_nil: true do |io, store: nil, **options|
    calculate_signature(io, :sha256, format: :base64) unless store == :cache
  end

  add_metadata :kind do |io, **options|
    MeruAPI::Container["assets.parse_kind"].call(io).value_or("unknown")
  end

  Attacher.validate do
    validate_max_size 5.gigabytes
  end

  Attacher.promote_block { promote }
  Attacher.destroy_block { destroy }
end

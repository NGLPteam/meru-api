# frozen_string_literal: true

class Shrine
  module Plugins
    module StandardMetadata
      STALE_TIME = 15.minutes

      SafeTime = Dry::Types["params.time"].optional.fallback(nil)

      class << self
        def configure(uploader, **options)
          uploader.opts[:standard_metadata] ||= {}
          uploader.opts[:standard_metadata].merge!(options)
          uploader.opts[:standard_metadata][:stale_time] ||= STALE_TIME

          uploader.add_metadata :generated_at, skip_nil: true do |io, store: nil, **|
            Time.current.iso8601 unless store.nil?
          end

          uploader.add_metadata :sha256, skip_nil: true do |io, store: nil, **options|
            calculate_signature(io, :sha256, format: :base64) unless store.nil?
          end
        end

        # @return [void]
        def load_dependencies(uploader, **options)
          uploader.plugin :self_registering
          uploader.plugin :signature
          uploader.plugin :add_metadata
          uploader.plugin :refresh_metadata
        end
      end

      module InstanceMethods
        def stale_at = stale_time.ago

        def stale_time = opts.dig(:standard_metadata, :stale_time) || STALE_TIME
      end

      module AttacherMethods
        def stale? = file.stale?

        def stuck? = cached? && stale?
      end

      module FileMethods
        def generated_at = metadata["generated_at"].then { Shrine::Plugins::StandardMetadata::SafeTime.(_1) if _1.present? }

        def stale_at = uploader.stale_at

        def stale? = generated_at.then { _1.nil? || _1 < stale_at }
      end
    end

    register_plugin(:standard_metadata, StandardMetadata)
  end
end

# Enable the plugin automatically
Shrine.plugin :standard_metadata
